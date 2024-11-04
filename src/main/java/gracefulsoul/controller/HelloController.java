package gracefulsoul.controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import gracefulsoul.service.HelloService;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api")
public class HelloController {

	private final HelloService helloService;

	@GetMapping("/{name}")
	public String hello(@PathVariable(name = "name") String name) {
		return this.helloService.hello(name);
	}

}
