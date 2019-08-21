myPrayers is an app that allows you to store prayer requests.
When the applicaiton first launches, it will show a Verse of the Day (VOTD) from an API call from YouVersion
This will display for 7 seeconds before a login screen will appear
After logging into the app, a list of prayers will be shown (on first launch the table will be blank).
User can now add new prayers, or access the menu for additional options.
In the menu, user can modify profile information, turn off VOTD on startup, or sign off the application.


//Reviewer Details
Use login id jandoe@testemail.com.  Password is "prayers123"

myPrayers is an app that users Firebase for authentication/storage/database.  Please install cocopods using these directions...

**Use Terminal for all steps.**

1. Create a Podfile if you don't already have onee.
   $ cd your-project-directory

2. $ pod init

3. $ open Podfile.  Enter these pods...
    pod 'Firebase/Analytics'
    pod 'Firebase/Auth'
    pod 'Firebase/Storage'
    pod 'Firebase/Database'

4. $ pod install

5. $ open your-project.xcworkspace


The VOTD is an api call to YouVersion to pull down a daily verse. This will display for 7 seconds.
After logging into the app, it will check to see if the users has values in the Core Data stack.  If not, it will save the
current user information.

After logging in, you can interact with the table as is standard with tableviews.  You can slide a cell row to expose options to modify or delete
data in a particular row.  You can click the plus  sign in the navigation bar to add a new prayer.  The menu button opens a programmically
desginged view.  This is not in the storybaord.

The options in the menu and profile settings should be intuitive.  The VOTD is set based on a User Default setting.
