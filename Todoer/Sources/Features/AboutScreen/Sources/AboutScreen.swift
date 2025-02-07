import SwiftUI
import Common
import ThemeAssets

// MARK: - AboutScreen

/// A view that displays information about the app, including privacy policy, terms of service, and app details
struct AboutScreen: View {
    var body: some View {
        VStack {
            List {
                privacyPolicySection
                termsOfServiceSection
                aboutTodoerSection
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .scrollContentBackground(.hidden)
        }
    }
}

// MARK: - ViewBuilders

extension AboutScreen {
    /// Section displaying the privacy policy information
    @ViewBuilder
    fileprivate var privacyPolicySection: some View {
        Section(
            header:
                Text(Constants.Text.privacyPolicyTitle)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.textBlack)
                .padding(.top, 24)
                .listRowInsets(EdgeInsets())
        ) {}
        Section(
            header:
                Text(Constants.Text.collectedInformationSection)
                .fontWeight(.bold)
                .foregroundColor(Color.textBlack)
                .listRowInsets(EdgeInsets())
        ) {
            Text(Constants.Text.collectedInformation)
                .font(.system(size: 14))
                .listRowInsets(EdgeInsets())
        }
        Section(
            header:
                Text(Constants.Text.useOfInformationSection)
                .fontWeight(.bold)
                .foregroundColor(Color.textBlack)
                .listRowInsets(EdgeInsets())
        ) {
            Text(Constants.Text.useOfInformation)
                .font(.system(size: 14))
                .listRowInsets(EdgeInsets())
        }
        Section(
            header:
                Text(Constants.Text.informationSharingSection)
                .fontWeight(.bold)
                .foregroundColor(Color.textBlack)
                .listRowInsets(EdgeInsets())
        ) {
            Text(Constants.Text.informationSharing)
                .font(.system(size: 14))
                .listRowInsets(EdgeInsets())
        }
    }

    /// Section displaying the terms of service information
    @ViewBuilder
    fileprivate var termsOfServiceSection: some View {
        Section(
            header:
                VStack(alignment: .leading) {
                    Divider().padding(.bottom, 16)
                    Text(Constants.Text.termsOfServiceTitle)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color.textBlack)
                        .listRowInsets(EdgeInsets())
                }.listRowInsets(EdgeInsets())
        ) {}
        Section(
            header:
                Text(Constants.Text.acceptableUseSection)
                .fontWeight(.bold)
                .foregroundColor(Color.textBlack)
                .listRowInsets(EdgeInsets())
        ) {
            Text(Constants.Text.acceptableUse)
                .font(.system(size: 14))
                .listRowInsets(EdgeInsets())
        }
        Section(
            header:
                Text(Constants.Text.responsibilitiesSection)
                .fontWeight(.bold)
                .foregroundColor(Color.textBlack)
                .listRowInsets(EdgeInsets())
        ) {
            Text(Constants.Text.responsibilities)
                .font(.system(size: 14))
                .listRowInsets(EdgeInsets())
        }
        Section(
            header:
                Text(Constants.Text.changesToTermsSection)
                .fontWeight(.bold)
                .foregroundColor(Color.textBlack)
                .listRowInsets(EdgeInsets())
        ) {
            Text(Constants.Text.changesToTerms)
                .font(.system(size: 14))
                .listRowInsets(EdgeInsets())
        }
        Section(
            header:
                Text(Constants.Text.terminationOfServiceSection)
                .fontWeight(.bold)
                .foregroundColor(Color.textBlack)
                .listRowInsets(EdgeInsets())
        ) {
            Text(Constants.Text.terminationOfService)
                .font(.system(size: 14))
                .listRowInsets(EdgeInsets())
        }
    }

    /// Section displaying information about the app version and copyright
    @ViewBuilder
    fileprivate var aboutTodoerSection: some View {
        Section(
            header:
                Divider().padding(.bottom, 16)
                .listRowInsets(EdgeInsets())
        ) {
            Text(
                "\(AppInfo.appName) \(AppInfo.appVersion) (\(AppInfo.buildNumber)) - \(AppInfo.environment)\n\(Constants.Text.copyright)"
            )
            .font(.system(size: 14))
            .listRowInsets(EdgeInsets())
        }
    }
}

// MARK: - Constants

extension AboutScreen {
    /// Constants used throughout the about screen
    fileprivate struct Constants {
        /// Text constants for various sections and content
        struct Text {
            /// Title for the about section
            static let aboutTodoer = "About Todoer"
            /// Copyright notice
            static let copyright = " 2024 Todoer. All rights reserved."
            /// Title for privacy policy section
            static let privacyPolicyTitle = "Privacy Policy"
            /// Title for collected information section
            static let collectedInformationSection = "Collected Information"
            /// Details about collected information
            static let collectedInformation =
                "· Log data, such as your username.\n· Contact information, like your email address.\n· Usage data, including the app features you utilize."
            /// Title for use of information section
            static let useOfInformationSection = "Use of Information"
            /// Details about use of information
            static let useOfInformation =
                "· We personalize your experience within the app.\n· We enhance and optimize our services.\n· We keep you informed about updates and announcements."
            /// Title for information sharing section
            static let informationSharingSection = "Information Sharing"
            /// Details about information sharing
            static let informationSharing =
                "· We do not share your personal information with third parties without your consent, except when necessary to provide our services."
            /// Title for terms of service section
            static let termsOfServiceTitle = "Terms of Service"
            /// Title for acceptable use section
            static let acceptableUseSection = "Acceptable Use"
            /// Details about acceptable use
            static let acceptableUse =
                "· You commit to using the app in a legal and ethical manner.\n· You will not infringe on the app's intellectual property rights."
            /// Title for responsibilities section
            static let responsibilitiesSection = "Responsibilities"
            /// Details about responsibilities
            static let responsibilities = "· We are not liable for data loss or service interruptions."
            /// Title for changes to terms section
            static let changesToTermsSection = "Changes to Terms"
            /// Details about changes to terms
            static let changesToTerms =
                "· We reserve the right to modify these terms at any time. You will be notified of significant changes."
            /// Title for termination of service section
            static let terminationOfServiceSection = "Termination of Service"
            /// Details about termination of service
            static let terminationOfService =
                "· We reserve the right to terminate your access to the app for non-compliance with these terms."
        }
    }
}

/// Preview provider for the about screen
struct AboutScreen_Previews: PreviewProvider {
    static var previews: some View {
        About.Builder.makeAbout()
    }
}
