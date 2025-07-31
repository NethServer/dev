---
layout: default
title: Container Best Practices
nav_order: 7
---

# Best Practices for creating secure containers

Creating secure containers is essential to minimize vulnerabilities and ensure the reliability of your applications. Below are some best practices to follow when building container images:

## 1. Use multi-stage builds

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

## 2. Use minimal base images

Whenever possible, use minimal base images like `Alpine` to reduce the attack surface and the number of vulnerabilities. For example:

```Dockerfile
FROM alpine:3.18
```
However, be cautious when using minimal images, as some software may not be fully compatible with them. For instance, MUSL (used in Alpine) can cause issues with certain applications. In such cases, consider using a more compatible base image like `Debian`,
maybe with the `slim` variant:

```Dockerfile
FROM debian:12.11-slim
```

## 3. Pin image versions

Always specify the version of the base image to ensure consistency and avoid unexpected changes. For example:
```Dockerfile
FROM alpine:3.18
```
Avoid using untagged or `latest` tags, as they can lead to unpredictable builds and runtime issues.

## 4. Consider dependency pinning

When installing packages with managers like `apk` or `apt`, you may choose to pin package versions to improve build reproducibility. For example:
```Dockerfile
RUN apk add --no-cache openssl=3.0.9-r1
```
However, strict pinning can delay important security updates. Weigh the benefits of reproducibility against the need for timely patches, and choose an approach that fits your project's requirements.

## 5. Automate updates with Renovate

Use tools like [Renovate](https://www.mend.io/renovate/) to automate dependency updates. Renovate can create pull requests for updated dependencies, allowing you to review and merge them as needed. This approach ensures that your images stay up-to-date with minimal manual effort.

## 6. Implement testing

- **Unit Testing**: At a minimum, create unit tests using the standard testing tools provided by your programming language (e.g., `unittest` for Python, `testing` for Go, etc.). This helps catch issues early and ensures that your code behaves as expected. Automated tests also increase confidence when upgrading dependencies; for example, if Renovate opens a pull request for a minor or patch update and all tests pass, you can safely merge the changes.
- **Test Frameworks**: While NethServer 8 uses [Robot Framework](https://robotframework.org/) for automated testing, each project is free to choose the testing framework that best fits its needs.

## 7. Generate SBOMs

Generate a Software Bill of Materials (SBOM) for your container images to track dependencies and their vulnerabilities. See the [SBOM section in security.md](security.md#sbom-software-bill-of-materials) for more details. 
