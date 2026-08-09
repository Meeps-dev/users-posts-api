from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]


def test_recommended_deployment_layout_is_present():
    expected_paths = (
        "deploy/users-posts-api.service",
        "scripts/package.sh",
        "scripts/deploy.sh",
        "scripts/health-check.sh",
        "scripts/rollback.sh",
    )
    legacy_paths = (
        "scripts/deploy-ec2.sh",
        "scripts/run-migrations.sh",
        "scripts/start-api.sh",
    )

    for relative_path in expected_paths:
        assert (PROJECT_ROOT / relative_path).is_file()

    for relative_path in legacy_paths:
        assert not (PROJECT_ROOT / relative_path).exists()


def test_systemd_service_uses_the_release_local_virtualenv():
    service = (PROJECT_ROOT / "deploy/users-posts-api.service").read_text()

    assert "WorkingDirectory=/opt/users-posts-api/current" in service
    assert "EnvironmentFile=/opt/users-posts-api/current/.env" in service
    assert "ExecStart=/opt/users-posts-api/current/.venv/bin/python" in service
    assert "/opt/users-posts-api/venv" not in service


def test_workflows_use_the_refactored_deployment_scripts():
    ci_workflow = (PROJECT_ROOT / ".github/workflows/ci.yml").read_text()
    cd_workflow = (PROJECT_ROOT / ".github/workflows/deploy-dev.yml").read_text()

    assert "bash scripts/package.sh" in ci_workflow
    assert "source/scripts/deploy.sh" in cd_workflow
    assert "source/deploy/users-posts-api.service" in cd_workflow

    assert "source/scripts/deploy-ec2.sh" not in cd_workflow
    assert "source/scripts/start-api.sh" not in cd_workflow
    assert "source/scripts/run-migrations.sh" not in cd_workflow


def test_deployment_smoke_data_is_unique_per_workflow_attempt():
    cd_workflow = (PROJECT_ROOT / ".github/workflows/deploy-dev.yml").read_text()

    assert 'smoke_test_id="${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}"' in cd_workflow
    assert "day76-${short_sha}-${smoke_test_id}@example.com" in cd_workflow
    assert "day76-${short_sha}@example.com" not in cd_workflow
    assert cd_workflow.count("--fail-with-body") >= 4
