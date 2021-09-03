[comment]: <> (Header Generated by ActionStatus 2.0.5 - 461)

[![Test results][tests shield]][actions] [![Latest release][release shield]][releases] [![swift 5.3 shield] ![swift 5.4 shield] ![swift 5.5 shield]][swift] ![Platforms: macOS, Linux][platforms shield]

[release shield]: https://img.shields.io/github/v/release/elegantchaos/LilliputWeb
[platforms shield]: https://img.shields.io/badge/platforms-macOS_Linux-lightgrey.svg?style=flat "macOS, Linux"
[tests shield]: https://github.com/elegantchaos/LilliputWeb/workflows/Tests/badge.svg
[swift 5.3 shield]: https://img.shields.io/badge/swift-5.3-F05138.svg "Swift 5.3"
[swift 5.4 shield]: https://img.shields.io/badge/swift-5.4-F05138.svg "Swift 5.4"
[swift 5.5 shield]: https://img.shields.io/badge/swift-5.5-F05138.svg "Swift 5.5"

[swift]: https://swift.org
[releases]: https://github.com/elegantchaos/LilliputWeb/releases
[actions]: https://github.com/elegantchaos/LilliputWeb/actions

[comment]: <> (End of ActionStatus Header)

# Lilliput on the Web

This is a web based host/driver for the Lilliput text adventure engine.

The host is written in Swift (as is Lilliput), and uses Vapor.

It's very crude at the moment, with pretty much no UI, and the user's entire input history is evaluated every time they visit their profile page -- which gets the job done, but isn't at all efficient.


