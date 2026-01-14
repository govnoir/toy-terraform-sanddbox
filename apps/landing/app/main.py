import os
import socket
import time
from dataclasses import dataclass
from typing import Optional, Tuple

from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from starlette.requests import Request

import psycopg
from psycopg.rows import dict_row

import redis


@dataclass(frozen=True)
class PgConfig:
    host: str
    port: int
    db: str
    user: str
    password: str


@dataclass(frozen=True)
class RedisConfig:
    host: str
    port: int


def _env(name: str, default: Optional[str] = None) -> str:
    val = os.getenv(name, default)
    if val is None or val == "":
        raise RuntimeError(f"Missing required env var: {name}")
    return val


def load_pg() -> PgConfig:
    return PgConfig(
        host=_env("POSTGRES_HOST"),
        port=int(_env("POSTGRES_PORT", "5432")),
        db=_env("POSTGRES_DB"),
        user=_env("POSTGRES_USER"),
        password=_env("POSTGRES_PASS"),
    )


def load_redis() -> RedisConfig:
    return RedisConfig(
        host=_env("REDIS_HOST"),
        port=int(_env("REDIS_PORT", "6379")),
    )


def pg_dsn(cfg: PgConfig) -> str:
    # psycopg3 DSN
    return f"host={cfg.host} port={cfg.port} dbname={cfg.db} user={cfg.user} password={cfg.password}"


def check_tcp(host: str, port: int, timeout_s: float = 1.0) -> Tuple[bool, str]:
    try:
        with socket.create_connection((host, port), timeout=timeout_s):
            return True, "tcp ok"
    except Exception as e:
        return False, f"tcp failed: {e.__class__.__name__}"


def check_postgres(cfg: PgConfig) -> Tuple[bool, str, Optional[str], Optional[str]]:
    """
    Returns: ok, message, server_version, latest_worker_ts
    """
    try:
        with psycopg.connect(
            pg_dsn(cfg), connect_timeout=2, row_factory=dict_row
        ) as conn:
            with conn.cursor() as cur:
                cur.execute("select version() as v;")
                ver = cur.fetchone()["v"]

                # Ensure table exists (landing is allowed to be "read-mostly", but creating the table is ok for toy env)
                cur.execute(
                    """
                    create table if not exists worker_heartbeat (
                      id bigserial primary key,
                      worker_id text not null,
                      ts timestamptz not null default now()
                    );
                    """
                )
                conn.commit()

                cur.execute(
                    "select worker_id, ts from worker_heartbeat order by ts desc limit 1;"
                )
                row = cur.fetchone()
                latest = None if row is None else f"{row['worker_id']} @ {row['ts']}"
                return True, "pg ok", ver, latest
    except Exception as e:
        return False, f"pg failed: {e.__class__.__name__}: {e}", None, None


def check_redis(cfg: RedisConfig) -> Tuple[bool, str]:
    try:
        r = redis.Redis(
            host=cfg.host, port=cfg.port, socket_connect_timeout=2, socket_timeout=2
        )
        pong = r.ping()
        return (pong is True), ("redis ok" if pong else "redis ping returned false")
    except Exception as e:
        return False, f"redis failed: {e.__class__.__name__}: {e}"


ENV = os.getenv("ENV", "dev")
APP = FastAPI()
templates = Jinja2Templates(
    directory=os.path.join(os.path.dirname(__file__), "templates")
)


@APP.get("/", response_class=HTMLResponse)
def index(request: Request):
    pg_cfg = None
    redis_cfg = None
    pg_status = (False, "not configured", None, None)
    redis_status = (False, "not configured")
    tcp_pg = (False, "not configured")
    tcp_redis = (False, "not configured")

    errors = []
    try:
        pg_cfg = load_pg()
        tcp_pg = check_tcp(pg_cfg.host, pg_cfg.port)
        pg_status = check_postgres(pg_cfg)
    except Exception as e:
        errors.append(str(e))

    try:
        redis_cfg = load_redis()
        tcp_redis = check_tcp(redis_cfg.host, redis_cfg.port)
        redis_status = check_redis(redis_cfg)
    except Exception as e:
        errors.append(str(e))

    payload = {
        "env": ENV,
        "now": time.strftime("%Y-%m-%d %H:%M:%S"),
        "pg": {
            "configured": pg_cfg is not None,
            "tcp_ok": tcp_pg[0],
            "tcp_msg": tcp_pg[1],
            "ok": pg_status[0],
            "msg": pg_status[1],
            "version": pg_status[2],
            "latest_heartbeat": pg_status[3],
        },
        "redis": {
            "configured": redis_cfg is not None,
            "tcp_ok": tcp_redis[0],
            "tcp_msg": tcp_redis[1],
            "ok": redis_status[0],
            "msg": redis_status[1],
        },
        "errors": errors,
    }
    return templates.TemplateResponse(
        "index.html", {"request": request, "data": payload}
    )


@APP.get("/healthz")
def healthz():
    # Keep this simple: if app runs, it’s healthy. Dependency health is on the landing page.
    return {"ok": True, "env": ENV}
