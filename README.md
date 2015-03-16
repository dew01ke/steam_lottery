<h1>LINKS:</h1>
http://skim.la/2012/01/16/rsa-public-key-interoperability-between-ruby-and-android/<br>
http://rxr.whitequark.org/mri/source/test/openssl/test_pkey_rsa.rb<br>
https://wiki.teamfortress.com/wiki/WebAPI<br>
Соотношение типов данных Ruby и MySQL: http://niugrad.blogspot.in/2008/03/ruby-rails-column-type-to-mysql.html

<h1>STEAM API:</h1>
<h3>ПОЛУЧЕНИЕ ИНВЕНТАРЯ</h3>
http://api.steampowered.com/IEconItems_440/GetPlayerItems/v0001/?key=XXXX&steamid=YYYY получение списка предметов TF<br>
http://api.steampowered.com/IEconItems_570/GetPlayerItems/v0001/?key=XXXX&steamid=YYYY получение списка предметов Dota<br>
http://api.steampowered.com/IEconItems_730/GetPlayerItems/v0001/?key=XXXX&steamid=YYYY получение списка предметов CS<br>
Для примера key=40203AB5100825DF97F990FCE10E7916, steamid=76561197996373589<br>
<h3>ПОЛУЧЕНИЕ ЦЕН НА АССЕТЫ</h3>
http://api.steampowered.com/ISteamEconomy/GetAssetPrices/v0001/?appid=440&key=40203AB5100825DF97F990FCE10E7916 получение цен на предметы(?) TF<br>
http://api.steampowered.com/ISteamEconomy/GetAssetPrices/v0001/?appid=570&key=40203AB5100825DF97F990FCE10E7916 получение цен на предметы(?) Dota<br>
http://api.steampowered.com/ISteamEconomy/GetAssetPrices/v0001/?appid=730&key=40203AB5100825DF97F990FCE10E7916 получение цен на предметы(?) CS<br>
<h3>ПОЛУЧЕНИЕ ЦЕНЫ НА ШМОТКУ ПО ЕЕ MARKET_HASH_NAME</h3>
https://steamcommunity.com/market/priceoverview/?country=RU&currency=1&appid=570&market_hash_name=Sentinel Hood

<h1>STEAM APPID:</h1>
440 = TF<br>
570 = DOTA2<br>
730 = CSGO<br>

<h1>ИНФОРМАЦИЯ О ПРОЕКТЕ</h1>
<h3>Основные принципы</h3>
Множество одновременных раздач вещей разных ценовых категорий
Суммарная стоимость слотов - 130-140%
Каждый слот имеет равный шанс победить + рандомные награды в виде экспы

<h3>МОДЕЛИ </h3>
User
* steamid
* email
* date of birth
* exp
* points
* is banned

Active raffle
* item pool id
* item steam id
* item value
* number of slots
* slot value
* slot info

Finished raffle short info(generated for each participant) - store for ~30 days
* user id
* item name
* points spent (on this raffle)
* date&time

Finished raffle full info (store in logs or in separate table)
* date&time
* item steam id
* item donated by (user id)
* item name
* item value
* number of slots
* slot value
* slot layout

Deposit/withdraw
* user id
* date&time
* (bool) is deposit
* (bool) is item
* iem name
* amount

Depo examples:<br>
(131, DATETIME, true, true, "AWP|Asiimov", 5800) - user won AWP|Asiimov and picked points <br>
(131, DATETIME, true, true, "AWP|Asiimov", 0) - user won AWP|Asiimov and picked item <br>
(131, DATETIME, true, false, "", 400) - user deposited 400 points <br>

Item pool:
* item DB id
* item steam id
* deposited by
* deposited on
* bot info

Item info:
* item steam id
* item price
* last updated

<h3>КОНТРОЛЛЕРЫ </h3>
/raffle - методы, обесечивающие функционал раздач <br>
/auth - авторизация ботов и юзеров <br>
/account - данные об аккаунте, статистика, внесение/снятие поинтов <br>
/admin - функционал админки <br>
/http - вспомогательные сетевые методы <br>
/papi - public API <br>
/trade - функционал трейдофферов

<h3>АДМИНКА </h3>
* просмотр логов
* бан/разбан пользователей
* управление раздачами:
-- досрочное закрытие раздач с возвратом вещей<br>
-- редактирование сетки раздач на главной странице<br>
* контроль ботов: <br>
-- статус логина ботов (наличие токенов, ид сессии)<br>
-- примерная суммарная стоимость вещей на боте <br>
-- редактирование инфо о ботах <br>
-- просмотр инвентаря ботов <br>
-- обмен с ботами <br>
-- обмен между ботами <br>
-- добавление/удаление ботов <br>
-- статистика пула вещей <br>
-- просмотр инфо об авторизации в SteamGuard <br>
* добавление Новостей на главную страницу
* переключения сайта в режим ремонта, с возможностью админам заходить по openid
* добавление\удаление админов

<h1>ЗАДАНИЯ:</h1>
<h2><s>(ДЛЯ ВЛАДА) РЕАЛИЗАЦИЯ КОНТРОЛЛЕРА ПУБЛИЧНЫХ АПИ:</s></h2>
<h2><s>(ДЛЯ ИЛЬИ) РЕАЛИЗАЦИЯ КЛИЕНТА ПОЧТЫ:</s></h2>
<h2><s>(ДЛЯ ИЛЬИ) КОНТРОЛЛЕР ТРЕЙДОФФЕРОВ</s></h2>
<h2><s>(ДЛЯ ВЛАДА) ЧАСТИЧНАЯ РЕАЛИЗАЦИЯ БАЗЫ ДАННЫХ</s></h2>

<h3>(ДЛЯ АНДРЕЯ) ПРОЕКТИРОВАНИЕ И ВЕРСТКА ДИЗАЙНА:</h3>
Нарисовать и сверстать дизайн для: 
* <s>главной страницы (нарисовано, сверстано)</s>
* <s>страницы раздачи (нарисовано, сверстано)</s>
* страницы новости
* страницы джекпота
* страницы админки
