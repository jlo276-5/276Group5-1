<% provide(:title, 'FAQ') %>
<% provide(:page_title, 'FAQ') %>

## I am having trouble registering for StuHub

Make sure to register for StuHub with a valid e-mail address, and enter a password of 6 characters or more.

If you have registered and not received a verification e-mail in your inbox, your mail client may have regarded it as spam. Please check your junk mail.

## My course is not available in the Course Hub

Courses are featured from an academic institutions official list.

If you do not see a course, it is either not being offered at this time, or your institution has not updated the official list.

In either case, please check with your academic institution.

In the future, we plan on allowing students from institutions without official data to add their own courses.

## I forgot my password!

Simply click on the forgot password button located on the login page, or through <%= link_to 'here', new_password_reset_path %>.

You will be asked to enter your email address, where you will be sent an e-mail to change your password.

## I don't want others to view my list of courses or personal information about me. How can I hide it?

StuHub offers customizable privacy settings to control what information is public to others.

* Upon login, click on edit profile located in the user menu.
* To the right of each field, you can check on uncheck the show button to control what information others are able to view.

## My question isn't in the help guide or in this FAQ

Send your questions to use with the <%= link_to 'Contact Form', help_item_path(page: 'contact') %>. That helps us improve this help guide and StuHub itself.
