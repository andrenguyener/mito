# Mito: Giving With Privacy In Mind
## Mission and Vision

Consumers have shifted from simply exchanging information on the internet to now engaging in financial transactions on a mobile application. Technologies such as Zelle and Venmo are built to make sending money convenient to consumers. Yet, similar technologies don’t exist for sending physical products. You cannot send a birthday present for your friends and families if you do not have any knowledge of their home address. Additionally, as a receiver, you would have to expose their physical address to senders. But, what if you don’t? What if you can eliminate this hassle while still securing your home address from other consumers?

Mito, derived from Latin for “giving with ease”, provides a social platform that lets users purchase products available on major online e-commerce shops, such as Amazon, to send to one another without exchanging physical addresses. Our solution offers a seamless process for buying goods for recipients while protecting users’ address information at all cost. We aim to break through the address exchange barrier between consumers in an online peer-to-peer transaction. A transaction via Mito will no longer require users to share their private physical address with each other.

![TestImage](https://raw.github.com/andrenguyener/mito/screenshots/Add-An-Address.png)

## Table of Contents
  - [Features](#features)
    - [Register for a Mito Account](#registers-for-a-mito-account)
      - [Account Sign Up](#account-sign-up)
      - [Account Sign In](#account-sign-in)
      - [Profile Customization](#profile-customization)
      - [User Address Book](#user-address-book)
      - [Payment Methods](#payment-methods)
    - [Purchases Products on Mito](#purchases-products-on-mito)
	    - [Products Search](#products-search)
	    - [Shopping Cart](#shopping-cart)
	    - [Cart Checkout](#cart-checkout)
    - [Interacts in Mito Network](#interacts-in-mito-network)
	    - [Views Mito User Profile](#views-mito-user-profile)
	    - [Adds Users as Friends](#adds-users-as-friends)
	    - [Friends List](#friends-list)
    - [Confirms or Declines Friend Requests](#confirms-or-declines-friend-requests)
    - [Confirms or Declines Package Requests](#confirms-or-declines-package-requests)
    - [Views Packages Feed](#views-packages-feed)
	    - [Friends Feed](#friends-feed)
	    - [My Feed](#my-feed)
  - [Technologies](#technologies)
	  - [Go](#go)
	  - [NodeJS](#nodejs)
	  - [Server Hosting](#server-hosting)
	  - [Database Management](#database-management)
	  - [Amazon Product Advertising API](#amazon-product-advertising-api)
	  - [Ebay API](#ebay-api)
	  - [Google Maps API](#google-maps-api)
	  - [iOS Mobile Application](#ios-mobile-application)
  - [Contacts](#contacts)

## Features
### Registers for a Mito Account
#### Account Sign Up
Mito account registration is fairly easy and straightforward. You may sign up for a Mito account via our [website](https://projectmito.io/) or iOS mobile application. To create an account, you must provide your first name, last name, a valid email address, password (must be at least six characters), and birth of date. Please keep in mind that you must be at least 13 years old to register for an account. Upon creating an account, you agree to Mito terms and services. You may learn more about our Terms and Conditions on our [website](https://projectmito.io/terms.html).

#### Account Sign In

Mito currently only supports account sign in on our mobile application. You can sign into our platform with either your email address or username along with your secret password. Mito will verify the provided information with our database to ensure that the credentials are correct and valid.

#### Profile Customization

Upon registering an account, Mito creates a public profile for every user. Your public profile does not show sensitive information such as payment method or your address book. Mito public profile shows your first and last name, username (starts with ‘@’), and profile picture. By default, if you do not upload any picture, your profile picture will have the initials of your first and last name. You can upload a new profile picture in **My Profile** page (the instructions are below).

#### User Address Book

Mito users have the ability to save multiple addresses in their address book. You may provide each address with its own alias to make easier for you to choose an address. To add a new address to your account, you may navigate to address book in your **My Profile**. You may simply enter your address information corresponding text box or search the address on Google via Google Maps API.
SCREENSHOT

Selecting an address is required to sending and receiving a package. As a sender, you are required to select a billing address to continue the cart check out process. Please make sure that the billing address you selected is corresponded to the payment method you choose.

As a recipient, you are required to select a shipping address to confirm a package sent from other Mito users. The package you receive will be sent to the desired address you have in your address book.
SCREENSHOT

#### Payment Methods

Similar to your address book, Mito allows you to save payment methods (credit cards and/or debit cards) to your account. We securely store your payment information in our database. You may learn more about our [privacy policy on the website](https://projectmito.io/terms.html). Selecting a payment method is required upon checking out products in your cart. When adding a new payment method, we required that payment method is valid. If you provide a card that is already expired, the payment information will not be saved in your account.


### Purchases Products on Mito
#### Products Search

To allow for users to purchase goods online, Mito integrates others e-commerce store to our platform such as Amazon and Ebay. Currently, we only support products catalog from Ebay. You may search for products by entering words in the search textbox (shown below). Although the products are from Ebay, we do not support bidding items. Products that are found through our search are limited to only those that may be purchase right away with a fixed price.
Upon tapping on an item in the search result, you will be navigated to the product details page. The product details page includes information such as product name, seller name, price, and product description.
#### Shopping Cart

In a product details page, users have the ability to add the item to their cart. To add any product to the cart, simply choose a quantity by tapping on “Quantity” button and tap on “Add to Cart” to save the items in your cart. To view items in your cart, you may tap on the cart icon appears in the “Search” screen. Items you put in your cart will stay in the cart until you delete them from your cart. You will not lose any items in the cart upon signing out or exiting the app.

#### Cart Checkout

There are two methods for choosing a recipient for the products you are buying. One, you will be prompted to select a friend when you’re checking out the items in your cart. Or, you can pre-select a friend by navigating to the target user and tap on “Shop for…” button. Upon tapping on the button, you will be taken to the “Search” screen and a text box will appear right below the search bar confirming the person you are shopping for (as shown below).
SCREENSHOTS

 - Choose a Friend: There are two methods for choosing a recipient for the products you are buying. One, you will be prompted to select a friend when you’re checking out the items in your cart. Or, you can pre-select a friend by navigating to the target user and tap on “Shop for…” button. Upon tapping on the button, you will be taken to the “Search” screen and a text box will appear right below the search bar confirming the person you are shopping for.
 
 - Write a message: When sending items to another Mito user, you can attach a short note or message along with your packages. During the checkout process, you will be prompted to add a short message. The text box also supports Emoji. The receiver will be able to read the message you are attaching to the package. The message will also appear on your friend’s feed when users navigate to their respective profile.

- Select a paymethod method: The next step requires you to choose a payment method. You can select any payment method you already saved in your account or add a new payment information on the spot. Please refer to the Payment Method section to learn more about payment information. Your account will only be charged if the recipient accepts and confirms your package. You can learn more in the Confirm/Decline Package Request section.

- Confirms your purchase in order summary: After selecting a payment method, our app will take you to the order summary screen. In this page, you may confirm all the relevant information to make sure they are correct as expected. You can change the payment information, billing address, or message by tapping on the corresponding text.


### Interacts in Mito Network
#### Views Mito User Profile

As a Mito user, you may interact with other users by navigating to their profile. In their profile, you may request them to be your friend, view the number of friends they have, and look at packages they have received or sent to other Mito users (Feed). However, you can only view the message that is attached to the packages, not the content of the package. In addition, you may start shopping for the person directly from this page by tapping on “Shop for…” at the bottom of the page. By tapping on the button, you will be navigated to the Search screen.
#### Adds Users As Friends

To request for another Mito user to be your friend, you may tap on “Add Friend” button in their Profile page. This action will send a friend request to the corresponding users. If you already requested the user as a friend, you will see “Pending Friend” instead of “Add Friend”. If you are already a friend of the user, you will simply see “Friend” on their profile page.

#### Friends List

In Mito, you are able to view all the friends you added in the **Friends** tab at the bottom navigation. By toggling to the **Friends** tab, you will see your list of friends in your network or search for other users on Mito by using the **Search** bar at the top. To view your friends profile, you may simply tap on their name or picture from the list.


### Confirms or Declines Friend Requests

In Mito, you may view any friend pending requests in the **Notifications** tab at the bottom navigation. As a user, you have the power to accept or decline any users as your friend. The **Notifications** tab will notify you when you receive a new friend request. You can toggle to the **Notifications** tab to view the user who requested you as their friend. By tapping on “Confirm”, the user will be added to your friends list. By tapping on “Decline”, the notification will go away and the user will not be added to your friends list.


### Confirms or Declines Package Requests

Similar to pending friend requests, **Notifications** tab will also alert you of any incoming pending packages. These packages are sent by other users on Mito and awaiting for your approval to be shipped. By tapping on the notification item, you will be able to view the message attached to the package and confirm or decline the sent package. By tapping on “Decline”, the notification will go away and the sender will be notified that you didn’t accept the package. By tapping on “Confirm”, you will navigated to a screen where you may select a shipping address from your Address book or add a new shipping address. Upon selecting a shipping address, the package will be shipped to the address you chose.
SCREENSHOT

_Please note that if you do not confirm or decline the package in 7 business days, our platform will notify the senders that you haven’t responded to the package and cancel the sender’s order._


### Views Packages Feed
#### Friends Feed

In the **Home** tab at the bottom navigation, you will be able to see packages sent and/or received in your friend network. The “Friends” section of the **Home** tab lists the transactions made in your friend network. Each item in the list shows the sender and receiver name along with the message attached to the transactions. Tapping on an item from the list will take you to a screen to view the package on a separate screen.

#### My Feed

In addition to the “Friends” feed, you can also view only the confirmed packages that you have sent or received. By tapping on the “Me” sections of the Home tab, the screen lists only the packages you have accepted and successfully sent to other users on Mito. Similar to the items in “Friend” section, you may view the details of a package on a separate screen by tapping on an item.

## Technologies
### Go
Is a modern language that allowed for concurrency, is open sourced, strict variable types, and is fast when compiling, running, developing, and deploying. The language is simple and keeps the code written neat and easy to read. Documentation and community is well built allowing for ease of help and use.

### NodeJS
Clean and usable which makes it ideal for real-time data-intensive applications. Runs on an engine developed by Google which allows for its fast operational speeds. Ability to leverage node packages and libraries to integrate. Backed by a large community to seek help.

### Server Hosting
Digital Ocean - Allowed for creation and deletion of droplets with ease and contained an intuitive navigation compared to AWS.

### Database Management
Mito utilized the relational database design offered by Microsoft Azure. Microsoft Azure database offers a stable physical database design that follows the ACID principles. By storing our data in a SQL database, it ensures the information stored will be of valid data types, operations execute in explicit transactions, and can be rollback if any in-flight transaction fails. With the integration of Microsoft Azure SQL database, we can enforce policy and constraints on data that is flowing to the database.
In addition, since we are storing financial and personal encrypted information, we have to ensure that all the data is properly connected to corresponding users. Through the benefit of foreign key constraints in a SQL database, it enables us to achieve this. Furthermore, our mobile application frequently connects to the database to pull relevant data for users. Since our SQL database is optimized for reading performance, reading operations are faster for our users, which ultimately increases our server’s throughputs. As a result, Microsoft Azure SQL database fits well with our application.

### Amazon Product Advertising API
As mentioned, Mito platform integrates with some of the major e-commerce shops, including Amazon. Amazon e-commerce has an astounding user-based and inventory of products. According to our initial user research survey, over 90% of the participants have experience shopping products for themselves or others through Amazon. Such demand leads us to build a feature that allow users to search products available on Amazon. To achieve this feat, we became an Amazon associate through Amazon Associate Program and retrieve access to their product catalogs via Amazon Product Advertising API. By integrating the APA API, our platform is able search products on Amazon in real-time and view product related information such as product name, description, vendor, images, and price. With APA API, our users enjoy searching products on one of the most popular e-commerce platform.

### Ebay API
On top of Amazon, we already decided to integrate another popular e-commerce shop: eBay. As we building our service, we refrain from relying on one dependency to keep our service alive. To resolve this strong reliability, we chose to also incorporate eBay shop in our platform via their developer API. Ebay API allows our users to search for products available on eBay and directly purchase them. The API lets us browse eBay product listing, view product related information, and create orders through their API endpoints. As a result, our users can enjoy product available on popular e-commerce shops in the United State. In the future, we are looking to expand our product searching capability from other major e-commerce retailers such as Nordstrom, Alibaba, etc.

### Google Maps API
One of Mito’s features is adding new addresses via Google Maps. When a user decides to add a new address, Mito asks for use of the user’s location so Google Maps can suggest relevant locations close around. If the user wants to add a different address, they may search and Google will suggest addresses. This is a much simpler way for Mito users to add addresses quickly without having to fill in out the details on traditional text fields.

### iOS Mobile Application
Implementation the product in Xcode using Swift and Cocoapods makes it easier to build an app that follow the iOS design language. Our first customer base is iPhone users so we could concentrate on making sure the iOS experience was perfect before we expanded to Android. Our code is very reusable with methods being stored in AppData.swift if they are called in multiple places. It was important to us that any variables would only be declared and use in the necessary scope.
To enhance readability, we focused on prioritizing style as we coded. We followed lower camel casing for all our variable names and upper camel casing for our .swift file names. Any variable names had a prefix indicating what the variable type is such as “int” for integer, “dbl” for double, “str” for string, “bool” for booleans, and “arr” for arrays. Any Xcode type objects also had prefixes such as, “btn” for button, “lbl” for label, etc. Functions that involved a Xcode type object such as a button being pressed would say, “btnCartPressed” which would call a separate function start with prefix, “fnCartPressed” so that code would be easily interchangeable.

## Contacts


