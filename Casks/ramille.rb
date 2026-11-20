cask "ramille" do
  # "version,build": the release tag is v<version>-b<build> (for example v1.0.0-b1000099).
  version "1.0.0,1000099"
  sha256 "6c1324f3f5664a99b552248265d6d5d40c38fdbcd3b2492185dff3ae2d912b2a"

  url "https://github.com/ramah/ramille-releases/releases/download/v#{version.csv.first}-b#{version.csv.second}/Ramille-#{version.csv.first}.dmg"
  name "Ramille"
  desc "Git client that shows what you are about to push and the conflicts to expect"
  homepage "https://ramille.app/"

  livecheck do
    url "https://ramille.app/updates/appcast.xml"
    strategy :sparkle do |item|
      "#{item.short_version},#{item.version}"
    end
  end

  auto_updates true
  depends_on macos: :monterey

  app "Ramille.app"

  zap trash: [
    "~/Library/Application Support/com.glabs325.jalon",
    "~/Library/Preferences/com.glabs325.jalon.plist",
  ]
end
