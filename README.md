# Twitter Search for iOS

A sample app to demonstrate the use of native APIs to perform Twitter searches. The app is very simple: type the search query and see tweets. 

- Each tweet shows the text, the author's name and profile picture
- Search history is kept using Core Data and displayed on the initial screen. Just tap on a previous query to repeat the search
- Infinite scrolling: scroll to the bottom of the results page to load older tweets
- Pull down the results page to refresh the results
- Requests to the Twitter API are authenticated (OAuth) using the native Accounts/Social frameworks
- App localized in English and Brazilian Portuguese
- Universal app (iPhone + iPad)
- iOS 8.0+


Use the workspace file to load the project on Xcode (**Twitter Search.xcworkspace**).

## Dependencies

All dependencies are already on version control, but they can also be managed using CocoaPods. 

- [Mantle](https://github.com/Mantle/Mantle): used for JSON->model conversion
- [SDWebImage](https://github.com/rs/SDWebImage): used for loading and caching of the profile pictures
- [UIScrollView-InfiniteScroll](https://github.com/pronebird/UIScrollView-InfiniteScroll): used for the infinite scroll effect on the tweets screen