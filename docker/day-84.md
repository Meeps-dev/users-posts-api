# Day 84: GitHub Actions Integration, Final Validation, Documentation, and Cleanup

## What I Did

- Audited the application, Terraform, GitHub Actions, OIDC, and ECR configurations.
- Created a dedicated `github-ecr-push-role` with repository-scoped ECR permissions.
- Restricted the OIDC trust policy to `Meeps-dev/users-posts-api` on `main`.
- Verified `ecr:PutImage` was allowed while repository deletion and publishing to other repositories were denied.
- Added GitHub repository variables for the AWS Region, account ID, ECR repository, and ECR publisher role ARN.
- Pinned all third-party GitHub Actions to full commit SHAs.
- Added `container-build` and `container-publish` jobs to `ci.yml`.
- Configured PRs and feature branches to build and validate the image without AWS access or ECR publication.
- Configured `main` to authenticate through GitHub OIDC and publish a full-Git-SHA image to ECR.
- Built the image for `linux/amd64` with provenance and SBOM attestations disabled for ECR scan compatibility.
- Enabled GitHub Actions BuildKit layer caching.
- Verified feature-branch and pull-request pipelines passed while the ECR publish job was skipped.
- Verified the `main` pipeline assumed the expected OIDC role, pushed the image, recorded its digest, and completed the ECR scan.
- Pulled the GitHub Actions image from ECR by digest and ran it through Docker Compose with `--no-build`.
- Confirmed FastAPI, Alembic, PostgreSQL, health checks, and persisted user/post data worked correctly.

## What I Learned

- Container builds and image publication should be separate pipeline responsibilities.
- Pull requests should validate images without receiving cloud credentials.
- Job-level `id-token: write` limits OIDC token access to the publishing job.
- AWS permissions still come from the assumed IAM role, not from the GitHub permission alone.
- Full Git-SHA tags create traceability between source code and container images.
- Image digests provide the strongest immutable deployment reference.
- Pipeline conditions prevent feature branches and pull requests from publishing images.
- GitHub Actions cache improves repeated Docker build performance.
- Disabling provenance and SBOM attestations produced a directly scannable OCI image manifest for this ECR Basic Scanning workflow.
- Pulling and running the image by digest proves the registry artifact—not a local rebuild—is deployable.

## What Broke and How I Fixed It

### Unexpected Terraform IAM Policy Update

- **Problem:** The IAM plan showed `3 to add, 1 to change` instead of only three new resources.
- **Cause:** The existing Terraform apply policy also needed `s3:ListBucketVersions` and `s3:DeleteObjectVersion` for versioned S3 cleanup.
- **Fix:** Inspected the exact policy diff and confirmed the permissions were scoped to approved S3 bucket and object ARNs.
- **Verification:** Applied the reviewed plan with no resource destruction.

### PR and Feature-Branch Publication Risk

- **Risk:** Untrusted or unmerged code must not receive AWS credentials or publish images.
- **Fix:** Restricted the publishing job to `push` events on `refs/heads/main`, granted `id-token: write` only to that job, and restricted the IAM trust policy to the application repository's `main` branch.
- **Verification:** Feature and PR workflows built the image successfully, skipped publication, and created no ECR tags.

## Final Validation

- **Main commit:** `b32e390db177c719d7a7b5fac9de821a8946b4a5`
- **ECR digest:** `sha256:0ef32685c1edbf8ab4b29e6585802aa6df1b03170163a745c87252a3255e44f4`
- **Media type:** `application/vnd.oci.image.manifest.v1+json`
- **Runtime user:** `app:app`
- **ECR scan:** `COMPLETE`
- **Compose API:** healthy
- **PostgreSQL:** healthy
- **Alembic migration:** exited successfully
- **Persistent records:** returned successfully

## Result

- Completed secure Docker build validation for pull requests and feature branches.
- Completed main-only GitHub OIDC authentication and immutable ECR publication.
- Verified least-privilege IAM controls.
- Verified full Git-SHA image provenance and digest-based deployment.
- Verified the GitHub Actions-produced ECR image runs successfully with Docker Compose and PostgreSQL.
- Kept the ECR repository and OIDC publisher role for the Week 13 ECS Fargate deployment.