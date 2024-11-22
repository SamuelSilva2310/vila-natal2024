extends HttpRouter
class_name TestRouter


func handle_get(request, response):
	response.send(200, "Hello!")
