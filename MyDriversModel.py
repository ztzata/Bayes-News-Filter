import re
import requests
from bs4 import BeautifulSoup
import datetime
import pandas as pd
from sqlalchemy import create_engine
import jieba
from PySide6 import QtCore


class MyModel(QtCore.QAbstractTableModel):
    # update_finished = QtCore.pyqtSignal()  # For PyQt5。
    update_finished = QtCore.Signal()
    show_in_browser = QtCore.Signal(str)

    def run_in_QThread(self, func_to_run):
        self.thread = QtCore.QThread()
        func_inst = func_to_run.__self__
        func_inst.moveToThread(self.thread)
        func_inst.update_finished.connect(self.thread.quit)
        self.thread.started.connect(func_to_run)
        self.thread.start()

    @QtCore.Slot()
    def run_in_QThread_updateNewsToModel(self):
        self.thread.start()

    def __init__(self, parent=None):
        super(MyModel, self).__init__(parent)
        engine = create_engine('sqlite:///MyDrivers.sqlite',
                               echo=False,
                               connect_args={'check_same_thread': False})
        self.conn = engine.connect()
        sql_query = """
                            CREATE TABLE IF NOT EXISTS words (
                                word    TEXT    PRIMARY KEY   NOT NULL,
                                like    INT                   NOT NULL,
                                no_like INT                   NOT NULL,
                                total   INT                   NOT NULL
                            );
                            """
        self.conn.execute(sql_query)
        sql_query = "select * from words where word = 'Read Total';"
        rows = self.conn.execute(sql_query).fetchall()
        if rows == []:  # For first time use.
            sql_query = "INSERT INTO words VALUES ('Read Total', 0, 0, 1)"
            self.conn.execute(sql_query)
            self.p_like = 0.4
            self.p_nolike = 0.4
        else:
            self.p_like = rows[0][1] / rows[0][3]
            self.p_nolike = rows[0][2] / rows[0][3]
            # self.p_like = 0.4
            # self.p_nolike = 0.4

    @QtCore.Slot(int, str)
    def set_dates_to_get(self, get_days_num=2, get_from_date=None):
        if get_from_date is None:
            lookback_date = datetime.date.today() - datetime.timedelta(days=get_days_num - 1)
            try:
                sql_query = """
                        SELECT *
                        FROM news_unread
                        WHERE datetime = (SELECT max(datetime) FROM news_unread);
                        """
                news_unread_latest_datetime = pd.to_datetime(
                    pd.read_sql_query(sql_query, self.conn)['datetime'].values[0])
                news_unread_latest_link = pd.read_sql_query(
                    sql_query, self.conn)['link'].to_list()
            except BaseException:
                news_unread_latest_datetime = None
            try:
                sql_query = """
                        SELECT *
                        FROM news_read
                        WHERE datetime = (SELECT max(datetime) FROM news_read);
                        """
                news_read_latest_datetime = pd.to_datetime(
                    pd.read_sql_query(sql_query, self.conn)['datetime'].values[0])
                news_read_latest_link = pd.read_sql_query(
                    sql_query, self.conn)['link'].to_list()
            except BaseException:
                news_read_latest_datetime = None

            if (news_unread_latest_datetime is None
                    and news_read_latest_datetime is not None):
                self.news_latest_datetime = news_read_latest_datetime
                self.news_latest_link = news_read_latest_link
            elif (news_unread_latest_datetime is not None
                  and news_read_latest_datetime is None):
                self.news_latest_datetime = news_unread_latest_datetime
                self.news_latest_link = news_unread_latest_link
            elif (news_read_latest_datetime is not None
                  and news_unread_latest_datetime is not None):
                if news_unread_latest_datetime > news_read_latest_datetime:
                    self.news_latest_datetime = news_unread_latest_datetime
                    self.news_latest_link = news_unread_latest_link
                else:
                    self.news_latest_datetime = news_read_latest_datetime
                    self.news_latest_link = news_read_latest_link
            else:
                self.news_latest_datetime = pd.Timestamp(lookback_date)
                self.news_latest_link = []

            self.dates_to_get = pd.date_range(self.news_latest_datetime.date(),
                                              self.news_latest_datetime.date()
                                              + datetime.timedelta(days=get_days_num)
                                              ).strftime('%Y-%#m-%#d').tolist()
        else:
            try:
                self.dates_to_get = pd.date_range(pd.to_datetime(get_from_date).date(),
                                                  pd.to_datetime(get_from_date).date()
                                                  + datetime.timedelta(days=get_days_num)
                                                  ).strftime('%Y-%#m-%#d').tolist()
            except:
                self.dates_to_get = ['Date entered error', get_from_date]
        print(self.dates_to_get)

    @QtCore.Slot(result=str)
    def date_to_get(self):
        qml_date = ''
        qml_date_split = self.dates_to_get[-1].split('-')
        for t in qml_date_split:
            if len(t) < 2:
                t = '0' + t
            qml_date = qml_date + t
        return qml_date

    def update_news_to_model(self):
        """This method is website dependent. Modify this part before use!"""
        internet = 1
        news_page_url_base = 'https://news.mydrivers.com/update/'
        url_to_get_list = []
        if self.dates_to_get[0] == 'Date entered error':
            self.show_in_browser.emit(f'Date entered error: {self.dates_to_get[1]}')
            self.show_in_browser.emit('Please check the entered date.')
            self.thread.quit()
            return
        for date_to_get in self.dates_to_get:
            if pd.to_datetime(date_to_get).date() > (datetime.date.today() + datetime.timedelta(days=1)):
                break
            url_to_get = news_page_url_base + date_to_get + '_1.htm'
            url_to_get_list.append(url_to_get)
        if url_to_get_list == []:
            self.show_in_browser.emit(f'Date entered error: {self.dates_to_get}')
            self.show_in_browser.emit('Please check the entered date.')
            self.thread.quit()
            return

        def get_url_content(url_to_get):
            try:
                r = requests.get(url_to_get)
            except BaseException as e:
                print('Cannot establish Internet connection with server.\n', e)
                self.show_in_browser.emit('Cannot establish Internet connection with server.\n')
                self.show_in_browser.emit(str(e))
                nonlocal internet
                internet = 0
                return
            status_code = r.status_code
            if status_code == 200:
                bs = BeautifulSoup(r.content, 'html.parser')
                news_pages_list = bs.select('#newsleft > div > a')
                news_summary_list = bs.select('#newsleft > li')
            else:
                news_pages_list = []
                news_summary_list = []
            return status_code, news_pages_list, news_summary_list

        def extract_news_pages(news_pages_list: list) -> list:
            news_page_url_list = []
            for item in news_pages_list:
                news_page_url_tail = item.get('href')
                if item.text.isnumeric() and news_page_url_tail:
                    news_page_url = news_page_url_base + news_page_url_tail
                    news_page_url_list.append(news_page_url)
            return news_page_url_list

        def extract_news_summary(news_summary_list: list):
            for item in news_summary_list:
                news_title = item.find('h3').find('a').text
                news_link = 'https:' + item.find('h3').find('a').get('href')
                news_author = item.find(class_="newstiao4").text
                news_datetime_text = item.find(class_="news_plun hui2") \
                    .find('li').text
                match = re.search('\d{4}-\d{2}-\d{2} \d{2}:\d{2}',
                                  news_datetime_text)
                news_datetime = pd.to_datetime(match.group())
                # Naive Bayes classifier
                seg_list = jieba.cut(news_title)
                p_news_like_product = 1  # p_1*p_2*...*p_n
                p_news_like_1_product = 1  # (1-p_1)*(1-p_2)*...*(1-p_n)
                p_news_nolike_product = 1
                p_news_nolike_1_product = 1
                for word in seg_list:
                    sql_query = f"SELECT * FROM words WHERE word = '{word}';"
                    rows = self.conn.execute(sql_query).fetchall()
                    if rows == []:
                        p_word_like = 0.4
                        p_word_nolike = 0.4
                    else:
                        p_word_like = rows[0][1] / rows[0][3]
                        p_word_nolike = rows[0][2] / rows[0][3]
                    p_news_like_product = p_news_like_product * p_word_like
                    p_news_like_1_product = p_news_like_1_product * (1 - p_word_like)
                    p_news_nolike_product = p_news_nolike_product * p_word_nolike
                    p_news_nolike_1_product = p_news_nolike_1_product * (1 - p_word_nolike)
                p_news_like = 100 * p_news_like_product * self.p_like / (
                        p_news_like_product * self.p_like + p_news_like_1_product * (1 - self.p_like))
                p_news_nolike = 100 * p_news_nolike_product * self.p_nolike / (
                        p_news_nolike_product * self.p_nolike + p_news_nolike_1_product * (1 - self.p_nolike))
                p_news_like = round(p_news_like, 2)
                p_news_nolike = round(p_news_nolike, 2)

                self.news_df = self.news_df.append(
                    pd.DataFrame([[news_datetime,
                                   news_title,
                                   news_link,
                                   news_author,
                                   p_news_like,
                                   p_news_nolike]],
                                 columns=self.news_df.columns),
                    ignore_index=True)

        self.news_df = pd.DataFrame({'datetime': [], 'title': [], 'link': [],
                                     'author': [], 'like': [], 'no_like': []})

        for url_to_get in url_to_get_list:
            try:
                status_code, news_pages_list, news_summary_list = \
                    get_url_content(url_to_get)
            except:
                break
            if status_code == 200:
                print(url_to_get, ' loaded.')
                self.show_in_browser.emit(url_to_get + ' loaded.')
                extract_news_summary(news_summary_list)
            else:
                print(url_to_get, 'is not available. Status Code:', status_code)
                self.show_in_browser.emit(url_to_get + ' is not available. Status Code: ' + str(status_code))
                continue

            for news_page_url in extract_news_pages(news_pages_list):
                status_code, news_pages_list, news_summary_list = \
                    get_url_content(news_page_url)
                if status_code == 200:
                    extract_news_summary(news_summary_list)
                    print(news_page_url, ' loaded.')
                    self.show_in_browser.emit(news_page_url + ' loaded.')
                else:
                    print(url_to_get, 'is not available. Status Code:',
                          status_code)
                    self.show_in_browser.emit(url_to_get + ' is not available. Status Code: ' + str(status_code))
                    continue

        if internet == 0:
            self.thread.quit()
            return

        if (pd.to_datetime(self.dates_to_get[0]).date() == self.news_latest_datetime.date()):
            self.news_df.drop(self.news_df[self.news_df.datetime < self.news_latest_datetime].index,
                              inplace=True)
            try:
                for link in self.news_latest_link:
                    self.news_df.drop(self.news_df[self.news_df.link == link].index, inplace=True)
            except BaseException as e:
                print(e)
        else:
            sql_query = """SELECT datetime FROM news_unread"""
            tmp_news_datetime = pd.read_sql_query(sql_query, self.conn,
                                                  parse_dates='datetime')
            try:  # Raise error when news_read is empty.
                sql_query = """SELECT datetime FROM news_read"""
                tmp2_news_datetime = pd.read_sql_query(sql_query, self.conn,
                                                       parse_dates='datetime')
                tmp_news_datetime = tmp_news_datetime.append(tmp2_news_datetime, ignore_index=True)
                del tmp2_news_datetime
            except:
                pass
            tmp_news_datetime.datetime = tmp_news_datetime.datetime.apply(lambda x: x.date())
            for date in self.dates_to_get:
                date = pd.to_datetime(date).date()
                if (tmp_news_datetime.datetime == date).any():
                    sql_query = """SELECT link FROM news_unread"""
                    links = pd.read_sql_query(sql_query, self.conn)
                    try:
                        sql_query = """SELECT link FROM news_read"""
                        links2 = pd.read_sql_query(sql_query, self.conn)
                        links = links.append(links2, ignore_index=True)
                    except:
                        pass
                    links = links.link.tolist()
                    self.news_df = self.news_df.drop(self.news_df[self.news_df.link.isin(links)].index)
                    break

        self.news_df.sort_values('datetime', inplace=True)
        self.news_df.to_sql('news_unread', self.conn, index=False,
                            if_exists='append')
        sql_query = """
        SELECT * FROM news_unread ORDER BY datetime ASC
        """
        self._data = pd.read_sql_query(sql_query, self.conn,
                                       parse_dates='datetime')
        self._data['datetime'] = self._data['datetime'].dt.strftime('%m-%d %H:%M')
        self.update_finished.emit()

    def data(self, index, role=QtCore.Qt.DisplayRole):
        if index.isValid():
            if role == QtCore.Qt.DisplayRole:
                return str(self._data.iloc[index.row()][index.column()])
        return None

    def rowCount(self, parent=None):
        return len(self._data.values)

    def columnCount(self, parent=None):
        return self._data.columns.size

    def headerData(self, section, orientation, role):
        if role == QtCore.Qt.DisplayRole:
            # if orientation == QtCore.Qt.Horizontal:
            #     return ["DateTime", "Title", "Link", "Author", "Likeness", "NoLikeness"][section]
            if orientation == QtCore.Qt.Vertical:
                return str(section)

    @QtCore.Slot(list)
    def removeRow(self, rows):
        for row in sorted(rows, reverse=True):
            sql_query = f"""
                    DELETE FROM news_unread
                    WHERE link = '{self._data.iloc[row]['link']}';
                    """
            self.conn.execute(sql_query)
            self.beginRemoveRows(QtCore.QModelIndex(), row, row)
            self._data.drop(row, inplace=True)
            self.endRemoveRows()
        self._data.reset_index(drop=True, inplace=True)

    @QtCore.Slot(list)
    def deleteRead(self, rows):
        for row in sorted(rows, reverse=True):
            sql_query = f"""
                    DELETE FROM news_read
                    WHERE link = '{self._data.iloc[row]['link']}';
                    """
            self.conn.execute(sql_query)
            self.beginRemoveRows(QtCore.QModelIndex(), row, row)
            self._data.drop(row, inplace=True)
            self.endRemoveRows()
        self._data.reset_index(drop=True, inplace=True)

    @QtCore.Slot(list)
    def insertRow(self, rows):
        for row in rows:
            link = self._data.iloc[row]['link']
            sql_query = f"""
                        SELECT * FROM news_unread WHERE link = '{link}'
                        """
            tmp = pd.read_sql_query(sql_query, self.conn)
            tmp.to_sql(
                'news_read', self.conn, index=False, if_exists='append')
            sql_query = """
                        UPDATE words
                        SET total = total + 1
                        WHERE word = 'Read Total';
                        """
            self.conn.execute(sql_query)

    @QtCore.Slot(list)
    def like(self, rows: list):
        for row in rows:
            title = self._data.iloc[row]['title']
            seg_list = jieba.cut(title)
            for word in seg_list:
                sql_query = f"SELECT * FROM words WHERE word = '{word}';"
                rows = self.conn.execute(sql_query).fetchall()  # A list of tuples.
                if rows == []:
                    sql_query = f"INSERT INTO words VALUES ('{word}', 1, 0, 2);"
                    self.conn.execute(sql_query)
                else:
                    sql_query = f"""
                                UPDATE words
                                SET like = like + 1, total = total + 1
                                WHERE word = '{word}';
                                """
                    self.conn.execute(sql_query)
            sql_query = """
                        UPDATE words
                        SET like = like + 1
                        WHERE word = 'Read Total';
                        """
            self.conn.execute(sql_query)

    @QtCore.Slot(list)
    def no_like(self, rows: list):
        for row in rows:
            title = self._data.iloc[row]['title']
            seg_list = jieba.cut(title)
            for word in seg_list:
                sql_query = f"SELECT * FROM words WHERE word = '{word}';"
                rows = self.conn.execute(sql_query).fetchall()  # A list of one tuple.
                if rows == []:
                    sql_query = f"INSERT INTO words VALUES ('{word}', 0, 1, 2);"
                    self.conn.execute(sql_query)
                else:
                    sql_query = f"""
                                UPDATE words
                                SET no_like = no_like + 1, total = total + 1
                                WHERE word = '{word}';
                                """
                    self.conn.execute(sql_query)
            sql_query = """
                        UPDATE words
                        SET no_like = no_like + 1
                        WHERE word = 'Read Total';
                        """
            self.conn.execute(sql_query)

    @QtCore.Slot(str)
    def show_like(self, percentage):
        self.beginResetModel()
        tmp = self._data.loc[self._data.author == 'Zhengogo']
        self._data = self._data.loc[self._data.like >= (100 - int(percentage))]
        links = self._data.link.tolist()
        self._data = self._data.append(tmp[~tmp.link.isin(links)], ignore_index=True)
        self._data.sort_values("datetime", ascending=True, inplace=True)
        self.endResetModel()

    @QtCore.Slot(str)
    def noshow_nolike(self, percentage):
        self.beginResetModel()
        tmp = self._data.loc[self._data.author == 'Zhengogo']
        self._data = self._data.loc[self._data.no_like <= (100 - int(percentage))]
        links = self._data.link.tolist()
        self._data = self._data.append(tmp[~tmp.link.isin(links)], ignore_index=True)
        self._data.sort_values("datetime", ascending=True, inplace=True)
        self.endResetModel()

    @QtCore.Slot()
    def load_unread(self):
        self.beginResetModel()
        sql_query = """
        SELECT * FROM news_unread ORDER BY datetime ASC
        """
        self._data = pd.read_sql_query(sql_query, self.conn,
                                       parse_dates='datetime')
        self._data['datetime'] = self._data['datetime'].dt.strftime('%m-%d %H:%M')
        self.endResetModel()

    @QtCore.Slot()
    def load_read(self):
        self.beginResetModel()
        try:
            sql_query = """
            SELECT * FROM news_read ORDER BY datetime ASC
            """
            self._data = pd.read_sql_query(sql_query, self.conn,
                                           parse_dates='datetime')
            self._data['datetime'] = self._data['datetime'].dt.strftime('%m-%d %H:%M')
        except:
            self._data.drop(self._data.index, inplace=True)
        self.endResetModel()
