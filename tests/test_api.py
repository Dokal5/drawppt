from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def sample_payload(project_id: str = "demo"):
    return {
        "projectId": project_id,
        "pages": [
            {
                "pageId": "p1",
                "canvas": {"width": 1170, "height": 2532},
                "elements": [
                    {
                        "type": "text",
                        "x": 100,
                        "y": 120,
                        "w": 500,
                        "h": 80,
                        "text": "Welcome",
                    },
                    {
                        "type": "button",
                        "x": 100,
                        "y": 300,
                        "w": 320,
                        "h": 90,
                        "text": "Continue",
                    },
                ],
                "style": {"mode": "lowfi", "theme": "gray"},
            }
        ],
    }


def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_generate_success():
    r = client.post("/v1/projects/demo/generate", json=sample_payload("demo"))
    assert r.status_code == 200
    assert r.json()["status"] == "generated"


def test_generate_mismatch():
    r = client.post("/v1/projects/other/generate", json=sample_payload("demo"))
    assert r.status_code == 400


def test_export_pptx_and_download():
    export_resp = client.post("/v1/projects/demo/export/pptx", json=sample_payload("demo"))
    assert export_resp.status_code == 200
    export_id = export_resp.json()["exportId"]

    dl = client.get(f"/v1/exports/{export_id}")
    assert dl.status_code == 200
    assert dl.headers["content-type"].startswith(
        "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    )
