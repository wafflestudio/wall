package utils

import play.api.Play.current
import org.apache.commons.mail._
import com.typesafe.config.ConfigFactory
import models._
import play.api.Logger

object Mailer {

  lazy val config = ConfigFactory.load()
  lazy val host = config.getString("smtp.host")
  lazy val port = config.getInt("smtp.port")
  lazy val ssl = config.getBoolean("smtp.ssl")
  lazy val username = config.getString("smtp.user")
  lazy val password = config.getString("smtp.password")
  lazy val from = config.getString("smtp.from")
  lazy val rooturl = config.getString("rooturl")

  def send(subject: String, content: String, recipient: String) = {
    var email: Email = new HtmlEmail();
    email.setHostName(host);
    email.setSmtpPort(port);
    email.setAuthenticator(new DefaultAuthenticator(username, password));
    email.setSSL(ssl);

    email.setFrom(from);
    email.setSubject(subject);
    email.setMsg(content);
    email.addTo(recipient);
    //		email.send();

  }

  def sendVerification(user: User.Frozen) = {
    send("Verify your account at Infinite Wall", """
				<html>
					<p><a href="@URL"></a></p>
				</html>
				""".replaceAll("@URL", rooturl + "/user/verify?value="),
      user.email)
  }
}


