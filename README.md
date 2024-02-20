# Назначение

Приложение позволяет просматривать информацию о погоде в выбранных географических локациях:
- текущая погода;
- погода на день с интервалом 3 часа;
- погода на ближайшие 16 дней.

В приложении использована колекция иконок от Pascal Vleugels https://dribbble.com/pasxal
Приложение поддерживает темную и светлую темы, а так же локализацию (руский и английский языки).
Для получения данных применяется API openweathermap.com 
Загруженные данные кешируется в локальных файлах с использованием FileManager. Периодичность обновления кэша - 30 минут.

# Экраны приложения

## Основной экран
Основной экран выполнен на UIPageViewController, позволяюшем листать локации. Независимо от числа локаций приложение использует только три страницы контроллекра, обновляемые при пролистывании - предыдущую, текущую и следующую.

<img src="https://github.com/AlekseiTinkov/openweathermap/assets/124910352/393bfadf-25b5-40f3-8465-cc1d85d011b5" width="200"></img>
<img src="https://github.com/AlekseiTinkov/openweathermap/assets/124910352/674bc499-a438-44d1-858d-b69bebd4052b" width="200"></img>
<img src="https://github.com/AlekseiTinkov/openweathermap/assets/124910352/fd945fc0-3ccb-4b63-83eb-ef07b3b63faf" width="200"></img>

На каждой странице отображаются:
- заголовок с названием локации;
- информация о текущей погоде;
- горизонтально прокручиваемая коллекция с почасовым прогнозом погоды на день;
- вертикально прокручиваемая коллекция с прогнозом погоды на 16 дней.

При пустом списке локций отображается заглушка, нажатие на которую вызывает диалог добавления локаций.

<img src="https://github.com/AlekseiTinkov/openweathermap/assets/124910352/b074c850-4c31-428d-8f44-7f601da1126a" width="200"></img>

В левом верхнем углу основного экрана выводится кнопка меню, дующуя доступ к следующим функциям:
- добавление локации;
- удаление локации;
- редактирование списка локаций;
- настройки приложения.

<img src="https://github.com/AlekseiTinkov/openweathermap/assets/124910352/44b6ee8e-35b1-4a95-be1b-ecd798ebbf31" width="200"></img>

## Экран добавления локаций
Экран позволяет осуществлять поиск локаций по тексту, набранному в строке поиска.

<img src="https://github.com/AlekseiTinkov/openweathermap/assets/124910352/32457f0c-7924-44a8-96de-8d53c98e16db" width="200"></img>
<img src="https://github.com/AlekseiTinkov/openweathermap/assets/124910352/d2d410c4-12fd-457b-abef-7933fc576899" width="200"></img>

## Экран редактирования списка локаций
Экран позволяет сортировать список локаций и удалять локации из списка.

<img src="https://github.com/AlekseiTinkov/openweathermap/assets/124910352/46550d0c-f28e-4bab-93ab-133be4dfa6a6" width="200"></img>
<img src="https://github.com/AlekseiTinkov/openweathermap/assets/124910352/1dc2bac3-172c-499f-af37-84151fde5e88" width="200"></img>

## Экран настроек
Экран позволяет выбрать единицы измерения и указать пользовательский ключ API.

<img src="https://github.com/AlekseiTinkov/openweathermap/assets/124910352/eda6df90-de57-45c6-b552-3925ef40a3d2" width="200"></img>
