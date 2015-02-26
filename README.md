<h1>LINKS:</h1>
http://skim.la/2012/01/16/rsa-public-key-interoperability-between-ruby-and-android/<br>
http://rxr.whitequark.org/mri/source/test/openssl/test_pkey_rsa.rb<br>
https://wiki.teamfortress.com/wiki/WebAPI<br>

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

<h1>STEAM TRADEOFFERS:</h1>
<b>url запроса:</b><br>
https://steamcommunity.com/tradeoffer/new/send<br><br>
<b>header запроса:</b><br>
Origin: https://steamcommunity.com<br>
User-Agent: USER_AGENT<br>
Content-Type: application/x-www-form-urlencoded; charset=UTF-8<br>
Referer: https://steamcommunity.com/tradeoffer/new/?partner=SHORT_PARTNER_ID<br>
Cookie: ALL_COOKIES<br>
Host: steamcommunity.com<br><br>
<b>body запроса:</b><br>
sessionid=COOKIE_SESSION_ID&<br>
serverid=1&<br>
partner=STEAM64_ID&<br>
tradeoffermessage=ANYTHING&<br>
json_tradeoffer={"newversion":true,"version":4,"me":{"assets":[{"appid":570,"contextid":"2","amount":1,"assetid":"5452553857"},{"appid":570,"contextid":"2","amount":1,"assetid":"5454103477"},{"appid":570,"contextid":"2","amount":1,"assetid":"5454103543"}],"currency":[],"ready":false},"them":{"assets":[],"currency":[],"ready":false}}&<br>
captcha=&<br>
trade_offer_create_params={}<br>

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
* getUserInfo
* getBackpack
* getItemPrice
* getSteam64
* getAllItems <br>
/trade - функционал трейдофферов

<h3>АДМИНКА </h3>
* просмотр логов
* бан/разбан
* закрытие раздач
* редактирование сетки раздач
* контроль ботов <br>
-статус логина ботов <br>
-примерная суммарная стоимость вещей на боте <br>
-редактирование инфо о ботах <br>
-просмотр инвентаря ботов <br>
-обмен с ботами <br>
-обмен между ботами <br>
-добавление/удаление ботов <br>
-статистика пула вещей <br>
-просмотр инфо об авторизации в SteamGuard <br>

<h1>ЗАДАНИЯ:</h1>
<h3>(ДЛЯ ИЛЬИ) РЕАЛИЗАЦИЯ КОНТРОЛЛЕРА ПУБЛИЧНЫХ АПИ:</h3>
-getUserInfo(steamid64, api_key)<br>
getBackpackByAppid(steamid64, api_key, appid)<br>
-getBackpack(steamid64 or steamlogin, appid)<br>
-getSteamId64(steamlogin)<br>
getAssetPrices(api_key, appid)<br>
getPricesByHashname(appid, market_hash_name)<br>

<h3>(ДЛЯ ИЛЬИ) РЕАЛИЗАЦИЯ КЛИЕНТА ПОЧТЫ:</h3>
По логину\паролю от почты получить оперделенное письмо и найти 5-ти символьный пароль и извлечь его от туда.
