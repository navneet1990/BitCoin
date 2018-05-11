# BitCoin
First this app is compatible with Apple Watch and Today Extension. This app  is developed to fetch current bitcoin price from server and update today price in every 60seconds. It also stores last 14 days of coin price. User can choose any currency (USD,EUR,GBP) .

NO THIRD Party Class or framework has been used in whole app

App is following MVVM architecture which make the UI super responsive .
It has following features:
	✓	iPhone App
	✓	Watch Compatibility
	✓	Today extension
	✓	Shared Data container for store data

Today Coin :
	▪	Show data todays data on main view
	▪	Shows last updated date label
	▪	User can choose between different currency(EUR,USD,GBP) and can switch any currency , immediately data will be reflected according to particular currency.
	▪	App has a infinite dispatch timer which refresh the Today service every 60secs., so that today coin value always stay updated

Last Two Weeks:
	▪	It also fetches Last two weeks coin rate and show on the table.
	▪	If user change currency sign, same will be reflected on table

Today Extension:
	▪	In Today extension widget, user can see the latest bit coin rate and last updated label
	▪	User can also switch between different currencies
	▪	In today extension, app is not refreshing data automatically but there is “refresh” button, if user wants to refresh . This is will call service and update the data

WatchKit
	▪	 Here user can see different currency buttons, last updated date label , rate label and button which push the screen to next page where user can see two weeks list.
	▪	Watch kit uses the same view-model object  as used in iPhone. 
	▪	It also refresh after 60 seconds

Data Storage:
	▪	Since app is sharing the data between today and watch kit extension, for that i am storing date in User Defaults by turning on the AppGroups.
	▪	Storing data in shared container, make is available across the extension and will update the same space.
	▪	In today extension, app is reading the data from shared space .
	▪	Today extension, won’t call the web service if user don’t press refresh button or is there is no data available in storage.

Compatibility:
	▪	App is compatible among both today and watch kit extension, in terms of data storage.
	▪	If data is updated anywhere, same will reflected on also location
	▪	App is fully compatible with watch kit, if user change anything either on watch or iPhone app,  same will be reflected on the other.
	▪	Suppose if i change currency from USD to GBP from watch, then same selection and data will be reflected in iPhone also and vice versa.

Unit Testing:
	•	App also also has few  unit test case to test view modal object and network response.

