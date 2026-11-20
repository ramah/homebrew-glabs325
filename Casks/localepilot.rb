cask "localepilot" do
  version "1.0.0"
  sha256 "88697b6db5258b42f60ed3f4e05e7eb24658c6c384d04349d9d4ca591b652af6"

  url "https://github.com/ramah/localepilot-releases/releases/download/v#{version}/LocalePilot-#{version}-macos.dmg"
  name "LocalePilot"
  desc "Translates ARB, i18next JSON and String Catalog files, checks placeholders"
  homepage "https://localepilot.app/"

  livecheck do
    url "https://localepilot.app/updates/appcast.xml"
    strategy :sparkle, &:short_version
  end

  auto_updates true
  depends_on macos: :ventura

  app "LocalePilot.app"

  zap trash: "~/Library/Containers/com.glabs325.localepilot"
end
