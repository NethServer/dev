---
layout: default
title: Best Practices
nav_order: 7
---

# Best Practices
{: .no_toc }

* TOC
{:toc}

## Selecting Open Source software

### Standing on the shoulders of giants

The phrase "standing on the shoulders of giants" is a metaphor for making progress in any field by building upon the knowledge and discoveries of those who came before. In the context of Open Source, it signifies the collaborative nature of software development where individuals leverage existing codebases and contribute back to the community. This approach allows for faster innovation and the creation of more robust and complex systems.

In Open Source software, this concept is embodied by the very nature of the work. Developers don't start from scratch; they utilize libraries, frameworks, and tools created by others. For example, a web developer might use React (a JavaScript library) or Bootstrap (a CSS framework), both of which are Open Source projects. By building upon these existing foundations, they can create applications more efficiently and with greater functionality.

### Golden rules for selecting Open Source software

When choosing Open Source software, consider the following golden rules to ensure you make the best decision for your needs:

1. **Prefer Open Source when possible**: Open Source software avoids vendor lock-in, fosters collaboration, and allows for customization to meet specific requirements.

2. **Check active development**: Verify if the software is actively maintained. Look at the number of contributors, the frequency of commits, and the activity in the issue tracker. An active community is crucial for reporting bugs, receiving help, and contributing pull requests.

3. **Look for backing companies**: While not a guarantee of quality, having a company behind the software often indicates a higher likelihood of long-term support and development, especially if the company generates revenue from the project.

4. **Seek third-party reviews**: Research reviews and opinions about the software on blogs, social media, and other platforms. Independent evaluations can provide valuable insights into the software's strengths and weaknesses.

5. **Evaluate documentation**: Good documentation is essential. It should be comprehensive, up-to-date, and easy to understand, making it easier to adopt and use the software effectively.

6. **Read the code**: If possible, review the source code. Clean, well-structured, and understandable code is a significant advantage, as it makes debugging and extending the software easier.

7. **Check usage statistics**: Look at independent metrics such as GitHub stars, the number of forks, or the volume of discussions on forums and social media. These can indicate the software's popularity and community engagement.

8. **Review security policies**: Ensure the software has a clear policy for updates and security disclosures. This is critical for maintaining a secure and reliable system.

9. **Assess developer engagement**: Developers who participate in conferences and public discussions demonstrate commitment and belief in their project. This is a positive sign of long-term investment.

10. **Test the software**: Try installing and configuring the software. Ease of installation and configuration is a significant plus, as it reduces the time and effort required to get started.

11. **Check license compatibility**: Select a project with a license that is compatible with your intended use. Ensure the license aligns with your organization's legal and operational requirements to avoid potential conflicts.

12. **Consider the project's lifecycle stage**: Evaluate where the project is in its lifecycle. Avoid projects in the "hype" stage unless you are willing to take risks or contribute actively. Mature projects with a stable community and fewer breaking changes are often more dependable.

13. **Assess dependency management**: Be cautious of projects with numerous or unstable dependencies. Fewer dependencies often mean less risk of breakage and easier maintenance.

14. **Perform benchmarks**: If you are considering multiple competing solutions, perform internal benchmarks using your specific use cases and data. This ensures the chosen software meets your performance and functionality requirements.


## Creating secure containers

Creating secure containers is essential to minimize vulnerabilities and ensure the reliability of your applications. Below are some best practices to follow when building container images:

### Prefer rootless containers

Whenever possible, run containers as a non-root user (rootless containers). Rootless containers improve security by reducing the risk of privilege escalation and limiting the impact of potential vulnerabilities. This practice is especially important when deploying containers on NethServer 8 or similar platforms. Ensure that the software you intend to run supports rootless operation, and configure your container runtime accordingly.

### Use multi-stage builds

Multi-stage builds help reduce the size of the final container image by separating the build environment from the runtime environment. This approach ensures that only the necessary artifacts are included in the final image, excluding build tools and dependencies.

For example, when building a Go application:
```Dockerfile
# Stage 1: Build
FROM golang:1.20 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp

# Stage 2: Runtime
FROM alpine:3.18
WORKDIR /app
COPY --from=builder /app/myapp .
CMD ["./myapp"]
```

### Use minimal base images

Whenever possible, use minimal base images like `Alpine` to reduce the attack surface and the number of vulnerabilities. For example:

```Dockerfile
FROM alpine:3.18
```
However, be cautious when using minimal images, as some software may not be fully compatible with them. For instance, MUSL (used in Alpine) can cause issues with certain applications. In such cases, consider using a more compatible base image like `Debian`,
maybe with the `slim` variant:

```Dockerfile
FROM debian:12.11-slim
```

### Pin image versions

Always specify the version of the base image to ensure consistency and avoid unexpected changes. For example:
```Dockerfile
FROM alpine:3.18
```
Avoid using untagged or `latest` tags, as they can lead to unpredictable builds and runtime issues.

### Consider dependency pinning

When installing packages with managers like `apk` or `apt`, you may choose to pin package versions to improve build reproducibility. For example:
```Dockerfile
RUN apk add --no-cache openssl=3.0.9-r1
```
However, strict pinning can delay important security updates. Weigh the benefits of reproducibility against the need for timely patches, and choose an approach that fits your project's requirements.

### Automate updates with Renovate

Use tools like [Renovate](https://www.mend.io/renovate/) to automate dependency updates. Renovate can create pull requests for updated dependencies, allowing you to review and merge them as needed. This approach ensures that your images stay up-to-date with minimal manual effort.

### Implement testing

- **Unit Testing**: At a minimum, create unit tests using the standard testing tools provided by your programming language (e.g., `unittest` for Python, `testing` for Go, etc.). This helps catch issues early and ensures that your code behaves as expected. Automated tests also increase confidence when upgrading dependencies; for example, if Renovate opens a pull request for a minor or patch update and all tests pass, you can safely merge the changes.
- **Test Frameworks**: While NethServer 8 uses [Robot Framework](https://robotframework.org/) for automated testing, each project is free to choose the testing framework that best fits its needs.

### Generate SBOMs

Generate a Software Bill of Materials (SBOM) for your container images to track dependencies and their vulnerabilities. See the [SBOM section in security.md](security.md#sbom-software-bill-of-materials) for more details. 


## Repository configuration

All software must be hosted on GitHub under the [NethServer](https://github.com/NethServer) or [Nethesis](https://github.com/Nethesis) organizations.

The GitHub repository configuration should follow some best practices to ensure the same level of security across all products.
Use Renovate for dependency management, while Dependabot only for alerts without automatic pull requests.

Access ``Settings`` -> ``Advanced Security`` then select the following options:
- ``Dependency graph``: enabled
  - under Dependency graph section, ``Automatic dependency submission``: disabled
- ``Dependabot alerts``: enabled
- ``Dependabot security updates``: disabled
- ``Grouped security updates``: disabled
- ``Dependabot version updates``: disabled
- ``Dependabot on Actions runners``: enabled
- ``Code scanning``: disabled, feel free to enable it if you want to use it
- ``Secret protection``: disabled, feel free to enable it if you want to use it
