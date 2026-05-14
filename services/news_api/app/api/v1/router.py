"""V1 router aggregation."""

from fastapi import APIRouter

from app.api.v1.endpoints.categories import router as categories_router
from app.api.v1.endpoints.news import router as news_router
from app.api.v1.endpoints.sources import router as sources_router


api_router = APIRouter()
api_router.include_router(categories_router)
api_router.include_router(news_router)
api_router.include_router(sources_router)

