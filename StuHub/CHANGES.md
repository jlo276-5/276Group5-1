# Change Log

## Iteration 1

### 2015.10.16
* Set up basic application  

### 2015.10.17
* Created login feature  
* Created database User  
* Created basic layout for welcome, users, home  

### 2015.10.18
* Created basic features  
* Update,display,delete user  
* Activate account and Reset Password  

### 2015.10.19
* Email Service established for activate account and reset password
* Security checks to prevent exploitation of routing failures  
* Improve page appearance, fonts  

### 2015.10.20
* Add site logo  
* Use a thinner navigation bar  
* Basic layout for User profile, editing of Users.  
* Added tests from RoR tutorial, also some custom ones  

### 2015.10.21
* Created a profile template for Users  
* Moved Login and Register forms to partials  

#### **__Iteration 1 Complete__**

## Iteration 2

### 2015.10.31
* SFU Course API Integration  
* TravisCI configuration  
* User attributes: last active, time zones  

### 2015.11.01 - 2015.11.05
* SFU API usage improvements  
* Require current password to change crucial user settings  
* Improve display of users and courses  

### 2015.11.06 - 2015.11.07
* Add attributes to allow for User Profile editing
* Implemented Course Management for Users: can now add courses and sections
* Privacy Settings for Users to control public profile
* Add framework for adding more institutions
* Quicker access to specific year/term/department in courses

### 2015.11.08
* Institutions system added, to support others later  
* Messaging system implemented with support for multiple channels
  * Currently supports Per-Course chat and posts
  * Uses PrivatePub on a separate Heroku app
* Updated various static texts

### 2015.11.09
* Groups function implemented
  * Administrative control, Per-Group chat and posts
  * Membership Requests available
* User email validation per institution (on signup only)
* User management system for Administrators
* Markdown support for various fields.
* Various fixes and layout

### 2015.11.10
* Various fixes
* Test Writing
* Basic calendar

#### **__Iteration 2 Complete__**

## Iteration 3

### 2015.11.11
* Accounts panel for Users to manage linked accounts
* JASIG CAS Authentication
* Dropbox Account Linking
* reCAPTCHA support

### 2015.11.14 - 2015.11.21
* Various Fixes

### 2015.11.22
* Display fixes in Messaging
* Markdown-based pages

### 2015.11.23
* Resque - Background Jobs System
* Reworked entire Institution/Term system.

### 2015.11.24  - 2015.11.25
* Introduce more emails about Account, optional emails for Course and Groups
* Schedule listing on Home improved

### 2015.11.26
* Reworked Posts system to be separate from Messages, support editing
* Faster Term database file loading
* Framework for new Help System

## 2015.11.27
* Contact System

## 2015.11.28
* Resources for Group and Course, can share links
* Changes to navigation bar

## 2015.11.29
* Fix message/post duplication
* Application-Wide Settings : maintenance mode, appearance of header/navigation
* Concept for new welcome/landing page
* Prevent long posts from taking over the page

## 2015.11.30
* DB Query optimizations
* Indicators for new Messages/Posts
* Show User's schedule on calendar
* Institution-wide Posts
* Recurring Events
* Test fixes

## 2015.12.01
* Finalize new-style landing page
* Some optimizations

#### **__Iteration 3 Complete__**
