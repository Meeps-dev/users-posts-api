# Day 83: Amazon ECR, IAM, Push, Pull, and Scan

## What I Did

* Created a reusable Terraform ECR module.
* Created a separate `ecr-dev` Terraform root and remote S3 state for Week 12.
* Provisioned the private `meeps-users-posts-api` ECR repository in `eu-west-2`.
* Enabled immutable image tags, AES-256 encryption, and Basic scan-on-push.
* Added registry-level `SCAN_ON_PUSH` filtering.
* Previewed the lifecycle policy before enabling it.
* Enabled lifecycle rules for old untagged and tagged images.
* Built and pushed the FastAPI image using a Git-SHA-based tag.
* Recorded the ECR image digest.
* Pulled the exact image back from ECR by digest.
* Ran the ECR-hosted image locally with Docker Compose using `--no-build`.
* Verified FastAPI health, Alembic migrations, PostgreSQL connectivity, and persisted data.

## What I Learned

* ECR repositories should be managed through Infrastructure as Code.
* Separate Terraform state prevents unrelated infrastructure from being recreated accidentally.
* Immutable tags protect existing image versions from being overwritten.
* Git-SHA tags provide source traceability while digests identify exact image content.
* Registry-level scanning rules control automatic ECR scans.
* Lifecycle policies should be previewed before enforcement.
* OCI image indexes and OCI image manifests are different artifact types.
* Pulling by digest provides stronger deployment validation than relying only on tags.

## What Broke and How I Fixed It

### Unsafe Terraform Plan

* **Problem:** The original Terraform root planned `51 to add`.
* **Cause:** It wanted to recreate previously destroyed VPC, ALB, EC2, RDS, and other resources.
* **Fix:** Created a dedicated `ecr-dev` Terraform root with a separate remote state.
* **Verification:** The new plan showed `1 to add, 0 to change, 0 to destroy`.

### Terraform Provider Download Timeout

* **Problem:** `terraform init` failed while downloading the AWS provider.
* **Cause:** Temporary connectivity issues reaching HashiCorp infrastructure.
* **Fix:** Kept the valid S3 backend and retried initialization using the locked provider version.
* **Verification:** Terraform initialized and validated successfully.

### ECR Scan Not Found

* **Problem:** ECR returned `ScanNotFoundException`.
* **Cause:** The image had not received a usable automatic scan.
* **Fix:** Configured registry-level Basic `SCAN_ON_PUSH` filtering for the repository.

### Unsupported Image Media Type

* **Problem:** ECR returned `UnsupportedImageTypeException`.
* **Cause:** BuildKit created an OCI image index instead of a directly scannable image manifest.
* **Fix:** Rebuilt for `linux/amd64` with provenance/SBOM attestations disabled.
* **Result:** The artifact became `application/vnd.oci.image.manifest.v1+json` and ECR scanning completed successfully.

### Immutable Tag Overwrite Failure

* **Problem:** Attempted to reuse the existing `00f06e819665-scanfix` tag for a different image.
* **Result:** ECR rejected the push because the repository uses immutable tags.
* **Resolution:** Kept immutability enabled and used unique image tags.

## Result

* Terraform-managed private ECR repository created.
* Dedicated Week 12 remote Terraform state configured.
* Immutable tags and AES-256 encryption enabled.
* Basic scan-on-push working.
* Lifecycle policy previewed and enabled.
* ECR vulnerability scan completed.
* Exact image digest recorded.
* Immutable-tag protection verified.
* ECR image successfully pulled and executed by digest.
* FastAPI, Alembic, and PostgreSQL validation passed.
* Completed the Day 83 Amazon ECR practical lab.
  ::: 
