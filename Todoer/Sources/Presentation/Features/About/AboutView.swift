import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            SwiftUI.List {
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

private extension AboutView {
    @ViewBuilder
    var privacyPolicySection: some View {
        Section(header:
                    Text(Constants.Text.privacyPolicyTitle)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.textBlack)
            .padding(.top, 24)
            .listRowInsets(EdgeInsets())
        ) {}
        Section(header:
                    Text(Constants.Text.collectedInformationSection)
            .fontWeight(.bold)
            .foregroundColor(.textBlack)
            .listRowInsets(EdgeInsets())
        ) {
            Text(Constants.Text.collectedInformation)
                .font(.system(size: 14))
                .listRowInsets(EdgeInsets())
        }
        Section(header:
                    Text(Constants.Text.useOfInformationSection)
            .fontWeight(.bold)
            .foregroundColor(.textBlack)
            .listRowInsets(EdgeInsets())
        ) {
            Text(Constants.Text.useOfInformation)
                .font(.system(size: 14))
                .listRowInsets(EdgeInsets())
        }
        Section(header:
                    Text(Constants.Text.informationSharingSection)
            .fontWeight(.bold)
            .foregroundColor(.textBlack)
            .listRowInsets(EdgeInsets())
        ) {
            Text(Constants.Text.informationSharing)
                .font(.system(size: 14))
                .listRowInsets(EdgeInsets())
        }
    }
    
    @ViewBuilder
    var termsOfServiceSection: some View {
        Section(header:
                    VStack(alignment: .leading) {
                        Divider().padding(.bottom, 16)
                        Text(Constants.Text.termsOfServiceTitle)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.textBlack)
                            .listRowInsets(EdgeInsets())
                    }.listRowInsets(EdgeInsets())
        ) {}
        Section(header:
                    Text(Constants.Text.acceptableUseSection)
            .fontWeight(.bold)
            .foregroundColor(.textBlack)
            .listRowInsets(EdgeInsets())
        ) {
            Text(Constants.Text.acceptableUse)
                .font(.system(size: 14))
                .listRowInsets(EdgeInsets())
        }
        Section(header:
                    Text(Constants.Text.responsibilitiesSection)
            .fontWeight(.bold)
            .foregroundColor(.textBlack)
            .listRowInsets(EdgeInsets())
        ) {
            Text(Constants.Text.responsibilities)
                .font(.system(size: 14))
                .listRowInsets(EdgeInsets())
        }
        Section(header:
                    Text(Constants.Text.changesToTermsSection)
            .fontWeight(.bold)
            .foregroundColor(.textBlack)
            .listRowInsets(EdgeInsets())
        ) {
            Text(Constants.Text.changesToTerms)
                .font(.system(size: 14))
                .listRowInsets(EdgeInsets())
        }
        Section(header:
                    Text(Constants.Text.terminationOfServiceSection)
            .fontWeight(.bold)
            .foregroundColor(.textBlack)
            .listRowInsets(EdgeInsets())
        ) {
            Text(Constants.Text.terminationOfService)
                .font(.system(size: 14))
                .listRowInsets(EdgeInsets())
        }
    }
    @ViewBuilder
    var aboutTodoerSection: some View {
        Section(header:
                    Divider().padding(.bottom, 16)
            .listRowInsets(EdgeInsets())
        ) {
            Text("\(AppInfo.appName) \(AppInfo.appVersion) (\(AppInfo.buildNumber)) - \(AppInfo.environment)\n\(Constants.Text.copyright)")
                .font(.system(size: 14))
                .listRowInsets(EdgeInsets())
        }
    }
}

// MARK: - Constants

private extension AboutView {
    struct Constants {
        struct Text {
            static let aboutTodoer = "About Todoer"
            static let copyright = "© 2024 Todoer. All rights reserved."
            static let privacyPolicyTitle = "Privacy Policy"
            static let collectedInformationSection = "Collected Information"
            static let collectedInformation = "· Log data, such as your username.\n· Contact information, like your email address.\n· Usage data, including the app features you utilize."
            static let useOfInformationSection = "Use of Information"
            static let useOfInformation = "· We personalize your experience within the app.\n· We enhance and optimize our services.\n· We keep you informed about updates and announcements."
            static let informationSharingSection = "Information Sharing"
            static let informationSharing = "· We do not share your personal information with third parties without your consent, except when necessary to provide our services."
            static let termsOfServiceTitle = "Terms of Service"
            static let acceptableUseSection = "Acceptable Use"
            static let acceptableUse = "· You commit to using the app in a legal and ethical manner.\n· You will not infringe on the app's intellectual property rights."
            static let responsibilitiesSection = "Responsibilities"
            static let responsibilities = "· We are not liable for data loss or service interruptions."
            static let changesToTermsSection = "Changes to Terms"
            static let changesToTerms = "· We reserve the right to modify these terms at any time. You will be notified of significant changes."
            static let terminationOfServiceSection = "Termination of Service"
            static let terminationOfService = "· We reserve the right to terminate your access to the app for non-compliance with these terms."
        }
    }
}

#Preview {
    AboutView()
}
