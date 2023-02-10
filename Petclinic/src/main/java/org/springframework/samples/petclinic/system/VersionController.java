package org.springframework.samples.petclinic.system;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;


private String version = System.getenv("VERSION");

@Controller
class VersionController {
    
    @GetMapping("/")
    public String getVersion() {
        return version;
    }
}
