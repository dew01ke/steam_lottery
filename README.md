Steam Lottery
=============================

##Полезные ссылки:
-----------------------------
http://skim.la/2012/01/16/rsa-public-key-interoperability-between-ruby-and-android/<br>
http://rxr.whitequark.org/mri/source/test/openssl/test_pkey_rsa.rb<br>
https://wiki.teamfortress.com/wiki/WebAPI<br>
Соотношение типов данных Ruby и MySQL: http://niugrad.blogspot.in/2008/03/ruby-rails-column-type-to-mysql.html

##Steam API:
-----------------------------
###ПОЛУЧЕНИЕ ИНВЕНТАРЯ
http://api.steampowered.com/IEconItems_440/GetPlayerItems/v0001/?key=XXXX&steamid=YYYY получение списка предметов TF<br>
http://api.steampowered.com/IEconItems_570/GetPlayerItems/v0001/?key=XXXX&steamid=YYYY получение списка предметов Dota<br>
http://api.steampowered.com/IEconItems_730/GetPlayerItems/v0001/?key=XXXX&steamid=YYYY получение списка предметов CS<br>
Для примера key=XXXX, steamid=76561197996373589<br>
###Получение цен на ассеты
http://api.steampowered.com/ISteamEconomy/GetAssetPrices/v0001/?appid=440&key=XXXX получение цен на предметы(?) TF<br>
http://api.steampowered.com/ISteamEconomy/GetAssetPrices/v0001/?appid=570&key=XXXX получение цен на предметы(?) Dota<br>
http://api.steampowered.com/ISteamEconomy/GetAssetPrices/v0001/?appid=730&key=XXXX получение цен на предметы(?) CS<br>
###Получение цены предмета по его MARKET_HASH_NAME
https://steamcommunity.com/market/priceoverview/?country=RU&currency=1&appid=570&market_hash_name=Sentinel Hood

##STEAM APPID:
440 = TF<br>
570 = DOTA2<br>
730 = CSGO<br>

Информация о проекте
=============================
##Основные принципы
* Множество одновременных раздач вещей разных ценовых категорий
* Суммарная стоимость слотов - 130-140%
* Каждый слот имеет равный шанс победить + рандомные награды в виде экспы

##Модели
* User
  * steamid
  * email
  * date of birth
  * exp
  * points
  * is banned

* Active raffle
  * item pool id
  * item steam id
  * item value
  * number of slots
  * slot value
  * slot info

* Finished raffle (short info, ~30 days)
  * user id
  * item name
  * points spent (on this raffle)
  * date&time

* Finished raffle full info (store in logs or in separate table)
  * date&time
  * item steam id
  * item donated by (user id)
  * item name
  * item value
  * number of slots
  * slot value
  * slot layout

* Deposit/withdraw
  * user id
  * date&time
  * (bool) is deposit
  * (bool) is item
  * iem name
  * amount

Depo examples:
(131, DATETIME, true, true, "AWP|Asiimov", 5800) - user won AWP|Asiimov and picked points <br>
(131, DATETIME, true, true, "AWP|Asiimov", 0) - user won AWP|Asiimov and picked item <br>
(131, DATETIME, true, false, "", 400) - user deposited 400 points <br>

* Item pool:
  * item DB id
  * item steam id
  * deposited by
  * deposited on
  * bot info

* Item info:
  * item steam id
  * item price
  * last updated

##Контроллеры
* **/raffle** - методы, обесечивающие функционал раздач
* **/auth** - авторизация ботов и юзеров
* **/account** - данные об аккаунте, статистика, внесение/снятие поинтов
* **/admin** - функционал админки
* **/http** - вспомогательные сетевые методы
* **/papi** - public API
* **/trade** - функционал трейдофферов

##Админка
* просмотр логов
* бан/разбан пользователей
* управление раздачами:
  * досрочное закрытие раздач с возвратом вещей<br>
  * редактирование сетки раздач на главной странице<br>
* контроль ботов: <br>
  * статус логина ботов (наличие токенов, ид сессии)<br>
  * примерная суммарная стоимость вещей на боте <br>
  * редактирование инфо о ботах <br>
  * просмотр инвентаря ботов <br>
  * обмен с ботами <br>
  * обмен между ботами <br>
  * добавление/удаление ботов <br>
  * статистика пула вещей <br>
  * просмотр инфо об авторизации в SteamGuard <br>
* добавление Новостей на главную страницу
* переключения сайта в режим ремонта, с возможностью админам заходить по openid
* добавление\удаление админов
