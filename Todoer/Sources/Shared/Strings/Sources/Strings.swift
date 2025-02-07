/// A namespace for all localized strings used in the application
public struct Strings {
    
    /// Strings used in list-related views
    public struct List {
        /// Placeholder text for new item input field
        public static let newItemPlaceholder = "Name..."
        /// Title for the sort button
        public static let sortButtonTitle = "Sort"
    }
    
    /// Strings used in the app menu
    public struct AppMenu {
        /// Title for the logout option
        public static let logoutOptionTitle = "Logout"
        /// Title for the about option
        public static let aboutOptionTitle = "About"
        /// Title for the delete account option
        public static let deleteAccountOptionTitle = "Delete account"
        /// Confirmation message shown before deleting an account
        public static let deleteAccountConfirmationText = "This action will delete your account and data. Are you sure?"
        /// Title for the delete button in confirmation dialogs
        public static let deleteButtonTitle = "Delete"
        /// Title for the cancel button in dialogs
        public static let cancelButtonTitle = "Cancel"
    }
    
    /// Strings used in the authentication screens
    public struct Authentication {
        /// Text displayed on the login screen
        public static let loginText = "Login"
        /// Title for the Google sign-in button
        public static let signInWithGoogleButtonTitle = "Sign in with Google"
        /// Motivational text shown on the login screen
        public static let getThingsDoneText = "Get things done!"
    }
    
    /// Strings used in error handling
    public struct Errors {
        /// Title for error dialogs
        public static let errorTitle = "Error"
        /// Title for the OK button in error dialogs
        public static let okButtonTitle = "Ok"
    }
    
    /// Strings used in the home screen
    public struct Home {
        /// Text displayed for the todos section
        public static let todosText = "To-dos"
        /// Title for the new todo button
        public static let newTodoButtonTitle = "New To-do"
    }
    
    /// Strings used in the invitations screen
    public struct Invitations {
        /// Text displayed for the invitations section
        public static let invitationsText = "Invitations"
        /// Text shown when someone wants to share a list
        public static let wantsToShareText = "Wants to share: "
        /// Title for the accept invitation button
        public static let acceptButtonTitle = "Accept"
        /// Title for the decline invitation button
        public static let declineButtonTitle = "Decline"
    }
    
    /// Strings used in the list items screen
    public struct ListItems {
        /// Title for the new item button
        public static let newItemButtonTitle = "New Item"
    }
    
    /// Strings used in the share list screen
    public struct ShareList {
        /// Text displayed for the share section
        public static let shareText = "Share"
        /// Text shown above the list of users the list is shared with
        public static let sharingWithText = "Sharing with"
        /// Title for the share button
        public static let shareButtonTitle = "Share"
        /// Placeholder text for the owner name input field
        public static let shareOwnerNamePlaceholder = "Your name..."
        /// Placeholder text for the email input field when sharing
        public static let shareEmailPlaceholder = "Email to share with..."
        /// Text shown when a list hasn't been shared yet
        public static let notSharedYetText = "Not shared yet"
    }
}
