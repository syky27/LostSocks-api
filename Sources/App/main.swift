import Vapor
import VaporMySQL
import Auth
import HTTP
import Cookies
import Turnstile
import TurnstileCrypto
import TurnstileWeb
import Fluent
import Foundation

try fireUpServer().run()
