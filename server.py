from datetime import date
import tornado.escape
import tornado.ioloop
import tornado.web
from tornado.httpserver import HTTPServer
import tornado.options
import os


class VersionHandler(tornado.web.RequestHandler):
	def get(self):
		response = {'version':'0.0.1',
					'last_build': date.today().isoformat()}
		self.write(response)


class LatLongRecieverHandler(tornado.web.RequestHandler):
	def get(self,pushCount,lat,long):
		print "This is the {0}th push from device, and the data is Latitude: {1}, Longtitude: {2} ".format(pushCount,lat,long)
		response = {'version':'0.0.2',
					'last_build': date.today().isoformat()}
		self.write(response)
	def post(self,pushCount,lat,long):
		print "This is the {0}th push from device, and the data is Latitude: {1}, Longtitude: {2} ".format(pushCount,lat,long)
		response = {'version':'0.0.3',
					'last_build': date.today().isoformat()}
		self.write(response)

Application = tornado.web.Application([
		(r"/version",VersionHandler),
		(r"/pushLatLong/(.*)/(.*)/(.*)",LatLongRecieverHandler)])


if __name__ == "__main__":
	tornado.options.parse_command_line()
	http_server = HTTPServer(Application)
	http_server.listen(8888)
	tornado.ioloop.IOLoop.instance().start()
