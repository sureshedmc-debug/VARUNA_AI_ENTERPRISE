"""Parameter router.

GET  /api/v1/parameters           – Fetch all parameters (from cache or vehicle)
GET  /api/v1/parameters/{name}    – Fetch single parameter
PUT  /api/v1/parameters/{name}    – Set parameter value
"""

from __future__ import annotations

import logging

from fastapi import APIRouter, HTTPException, Query, status

from app.dependencies import MAVLinkDep, ParameterDep
from app.models.parameter import Parameter, ParameterListResponse, ParameterSetRequest

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/v1/parameters", tags=["Parameters"])


@router.get(
    "",
    response_model=ParameterListResponse,
    summary="Get all parameters",
)
async def get_all_parameters(
    mavlink: MAVLinkDep,
    param: ParameterDep,
    refresh: bool = Query(False, description="Re-fetch all params from vehicle"),
) -> ParameterListResponse:
    """Return all ArduPilot parameters.

    By default returns the in-memory cache.  Pass ``?refresh=true`` to
    trigger a full PARAM_REQUEST_LIST cycle (may take up to 30 s on a
    heavily loaded link).
    """
    if not mavlink.is_connected:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Not connected to vehicle",
        )
    if refresh:
        try:
            params = param.fetch_all()
        except RuntimeError as exc:
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail=str(exc),
            ) from exc
    else:
        params = param.get_cached_parameters()

    return ParameterListResponse(count=len(params), parameters=params)


@router.get(
    "/{name}",
    response_model=Parameter,
    summary="Get single parameter",
)
async def get_parameter(
    name: str,
    mavlink: MAVLinkDep,
    param: ParameterDep,
) -> Parameter:
    """Return a single ArduPilot parameter by name.

    Checks the cache first; makes a live request if not cached.
    """
    if not mavlink.is_connected:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Not connected to vehicle",
        )
    result = param.get_parameter(name.upper())
    if result is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Parameter '{name}' not found",
        )
    return result


@router.put(
    "/{name}",
    response_model=Parameter,
    summary="Set parameter value",
)
async def set_parameter(
    name: str,
    body: ParameterSetRequest,
    mavlink: MAVLinkDep,
    param: ParameterDep,
) -> Parameter:
    """Write a new value for parameter *name*.

    The vehicle echoes back the updated value via PARAM_VALUE; this echo
    is returned in the response.
    """
    if not mavlink.is_connected:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Not connected to vehicle",
        )
    try:
        updated = param.set_parameter(name.upper(), body.value)
    except RuntimeError as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=str(exc),
        ) from exc
    if updated is None:
        raise HTTPException(
            status_code=status.HTTP_504_GATEWAY_TIMEOUT,
            detail=f"No ACK received for parameter '{name}'",
        )
    return updated
