-- Copyright (C) Yichun Zhang (agentzh)


local base = require "resty.core.base"
base.allows_subsystem('http', 'stream')


local ffi = require "ffi"
local C = ffi.C
local ffi_str = ffi.string
local ffi_gc = ffi.gc
local getfenv = getfenv
local error = error
local tonumber = tonumber
local errmsg = base.get_errmsg_ptr()
local get_string_buf = base.get_string_buf
local get_size_ptr = base.get_size_ptr
local FFI_DECLINED = base.FFI_DECLINED
local FFI_OK = base.FFI_OK
local subsystem = ngx.config.subsystem


local ngx_lua_ffi_ssl_set_der_certificate
local ngx_lua_ffi_ssl_clear_certs
local ngx_lua_ffi_ssl_set_der_private_key
local ngx_lua_ffi_ssl_raw_server_addr
local ngx_lua_ffi_ssl_server_name
local ngx_lua_ffi_ssl_raw_client_addr
local ngx_lua_ffi_cert_pem_to_der
local ngx_lua_ffi_priv_key_pem_to_der
local ngx_lua_ffi_ssl_get_tls1_version
local ngx_lua_ffi_parse_pem_cert
local ngx_lua_ffi_parse_pem_priv_key
local ngx_lua_ffi_set_cert
local ngx_lua_ffi_set_priv_key
local ngx_lua_ffi_free_cert
local ngx_lua_ffi_free_priv_key


if subsystem == 'http' then
    ffi.cdef[[
    int ngx_http_lua_ffi_ssl_set_der_certificate(ngx_http_request_t *r,
        const char *data, size_t len, char **err);

    int ngx_http_lua_ffi_ssl_clear_certs(ngx_http_request_t *r, char **err);

    int ngx_http_lua_ffi_ssl_set_der_private_key(ngx_http_request_t *r,
        const char *data, size_t len, char **err);

    int ngx_http_lua_ffi_ssl_raw_server_addr(ngx_http_request_t *r, char **addr,
        size_t *addrlen, int *addrtype, char **err);

    int ngx_http_lua_ffi_ssl_server_name(ngx_http_request_t *r, char **name,
        size_t *namelen, char **err);

    int ngx_http_lua_ffi_ssl_raw_client_addr(ngx_http_request_t *r, char **addr,
        size_t *addrlen, int *addrtype, char **err);

    int ngx_http_lua_ffi_cert_pem_to_der(const unsigned char *pem,
        size_t pem_len, unsigned char *der, char **err);

    int ngx_http_lua_ffi_priv_key_pem_to_der(const unsigned char *pem,
        size_t pem_len, unsigned char *der, char **err);

    int ngx_http_lua_ffi_ssl_get_tls1_version(ngx_http_request_t *r,
        char **err);

    void *ngx_http_lua_ffi_parse_pem_cert(const unsigned char *pem,
        size_t pem_len, char **err);

    void *ngx_http_lua_ffi_parse_pem_priv_key(const unsigned char *pem,
        size_t pem_len, char **err);

    int ngx_http_lua_ffi_set_cert(void *r, void *cdata, char **err);

    int ngx_http_lua_ffi_set_priv_key(void *r, void *cdata, char **err);

    void ngx_http_lua_ffi_free_cert(void *cdata);

    void ngx_http_lua_ffi_free_priv_key(void *cdata);
    ]]

    ngx_lua_ffi_ssl_set_der_certificate =
        C.ngx_http_lua_ffi_ssl_set_der_certificate
    ngx_lua_ffi_ssl_clear_certs = C.ngx_http_lua_ffi_ssl_clear_certs
    ngx_lua_ffi_ssl_set_der_private_key =
        C.ngx_http_lua_ffi_ssl_set_der_private_key
    ngx_lua_ffi_ssl_raw_server_addr = C.ngx_http_lua_ffi_ssl_raw_server_addr
    ngx_lua_ffi_ssl_server_name = C.ngx_http_lua_ffi_ssl_server_name
    ngx_lua_ffi_ssl_raw_client_addr = C.ngx_http_lua_ffi_ssl_raw_client_addr
    ngx_lua_ffi_cert_pem_to_der = C.ngx_http_lua_ffi_cert_pem_to_der
    ngx_lua_ffi_priv_key_pem_to_der = C.ngx_http_lua_ffi_priv_key_pem_to_der
    ngx_lua_ffi_ssl_get_tls1_version = C.ngx_http_lua_ffi_ssl_get_tls1_version
    ngx_lua_ffi_parse_pem_cert = C.ngx_http_lua_ffi_parse_pem_cert
    ngx_lua_ffi_parse_pem_priv_key = C.ngx_http_lua_ffi_parse_pem_priv_key
    ngx_lua_ffi_set_cert = C.ngx_http_lua_ffi_set_cert
    ngx_lua_ffi_set_priv_key = C.ngx_http_lua_ffi_set_priv_key
    ngx_lua_ffi_free_cert = C.ngx_http_lua_ffi_free_cert
    ngx_lua_ffi_free_priv_key = C.ngx_http_lua_ffi_free_priv_key

elseif subsystem == 'stream' then
    ffi.cdef[[
    int ngx_stream_lua_ffi_ssl_set_der_certificate(ngx_stream_lua_request_t *r,
        const char *data, size_t len, char **err);

    int ngx_stream_lua_ffi_ssl_clear_certs(ngx_stream_lua_request_t *r, char **err);

    int ngx_stream_lua_ffi_ssl_set_der_private_key(ngx_stream_lua_request_t *r,
        const char *data, size_t len, char **err);

    int ngx_stream_lua_ffi_ssl_raw_server_addr(ngx_stream_lua_request_t *r,
        char **addr, size_t *addrlen, int *addrtype, char **err);

    int ngx_stream_lua_ffi_ssl_server_name(ngx_stream_lua_request_t *r, char **name,
        size_t *namelen, char **err);

    int ngx_stream_lua_ffi_ssl_raw_client_addr(ngx_stream_lua_request_t *r,
        char **addr, size_t *addrlen, int *addrtype, char **err);

    int ngx_stream_lua_ffi_cert_pem_to_der(const unsigned char *pem,
        size_t pem_len, unsigned char *der, char **err);

    int ngx_stream_lua_ffi_priv_key_pem_to_der(const unsigned char *pem,
        size_t pem_len, unsigned char *der, char **err);

    int ngx_stream_lua_ffi_ssl_get_tls1_version(ngx_stream_lua_request_t *r,
        char **err);

    void *ngx_stream_lua_ffi_parse_pem_cert(const unsigned char *pem,
        size_t pem_len, char **err);

    void *ngx_stream_lua_ffi_parse_pem_priv_key(const unsigned char *pem,
        size_t pem_len, char **err);

    int ngx_stream_lua_ffi_set_cert(void *r, void *cdata, char **err);

    int ngx_stream_lua_ffi_set_priv_key(void *r, void *cdata, char **err);

    void ngx_stream_lua_ffi_free_cert(void *cdata);

    void ngx_stream_lua_ffi_free_priv_key(void *cdata);
    ]]

    ngx_lua_ffi_ssl_set_der_certificate =
        C.ngx_stream_lua_ffi_ssl_set_der_certificate
    ngx_lua_ffi_ssl_clear_certs = C.ngx_stream_lua_ffi_ssl_clear_certs
    ngx_lua_ffi_ssl_set_der_private_key =
        C.ngx_stream_lua_ffi_ssl_set_der_private_key
    ngx_lua_ffi_ssl_raw_server_addr = C.ngx_stream_lua_ffi_ssl_raw_server_addr
    ngx_lua_ffi_ssl_server_name = C.ngx_stream_lua_ffi_ssl_server_name
    ngx_lua_ffi_ssl_raw_client_addr = C.ngx_stream_lua_ffi_ssl_raw_client_addr
    ngx_lua_ffi_cert_pem_to_der = C.ngx_stream_lua_ffi_cert_pem_to_der
    ngx_lua_ffi_priv_key_pem_to_der = C.ngx_stream_lua_ffi_priv_key_pem_to_der
    ngx_lua_ffi_ssl_get_tls1_version = C.ngx_stream_lua_ffi_ssl_get_tls1_version
    ngx_lua_ffi_parse_pem_cert = C.ngx_stream_lua_ffi_parse_pem_cert
    ngx_lua_ffi_parse_pem_priv_key = C.ngx_stream_lua_ffi_parse_pem_priv_key
    ngx_lua_ffi_set_cert = C.ngx_stream_lua_ffi_set_cert
    ngx_lua_ffi_set_priv_key = C.ngx_stream_lua_ffi_set_priv_key
    ngx_lua_ffi_free_cert = C.ngx_stream_lua_ffi_free_cert
    ngx_lua_ffi_free_priv_key = C.ngx_stream_lua_ffi_free_priv_key
end

local _M = { version = base.version }


local charpp = ffi.new("char*[1]")
local intp = ffi.new("int[1]")


function _M.clear_certs()
    local r = getfenv(0).__ngx_req
    if not r then
        error("no request found")
    end

    local rc = ngx_lua_ffi_ssl_clear_certs(r, errmsg)
    if rc == FFI_OK then
        return true
    end

    return nil, ffi_str(errmsg[0])
end


function _M.set_der_cert(data)
    local r = getfenv(0).__ngx_req
    if not r then
        error("no request found")
    end

    local rc = ngx_lua_ffi_ssl_set_der_certificate(r, data, #data,
                                                          errmsg)
    if rc == FFI_OK then
        return true
    end

    return nil, ffi_str(errmsg[0])
end


function _M.set_der_priv_key(data)
    local r = getfenv(0).__ngx_req
    if not r then
        error("no request found")
    end

    local rc = ngx_lua_ffi_ssl_set_der_private_key(r, data, #data,
                                                          errmsg)
    if rc == FFI_OK then
        return true
    end

    return nil, ffi_str(errmsg[0])
end


local addr_types = {
    [0] = "unix",
    [1] = "inet",
    [2] = "inet6",
}


function _M.raw_server_addr()
    local r = getfenv(0).__ngx_req
    if not r then
        error("no request found")
    end

    local sizep = get_size_ptr()

    local rc = ngx_lua_ffi_ssl_raw_server_addr(r, charpp, sizep,
                                                      intp, errmsg)
    if rc == FFI_OK then
        local typ = addr_types[intp[0]]
        if not typ then
            return nil, nil, "unknown address type: " .. intp[0]
        end
        return ffi_str(charpp[0], sizep[0]), typ
    end

    return nil, nil, ffi_str(errmsg[0])
end


function _M.server_name()
    local r = getfenv(0).__ngx_req
    if not r then
        error("no request found")
    end

    local sizep = get_size_ptr()

    local rc = ngx_lua_ffi_ssl_server_name(r, charpp, sizep, errmsg)
    if rc == FFI_OK then
        return ffi_str(charpp[0], sizep[0])
    end

    if rc == FFI_DECLINED then
        return nil
    end

    return nil, ffi_str(errmsg[0])
end


function _M.raw_client_addr()
    local r = getfenv(0).__ngx_req
    if not r then
        error("no request found")
    end

    local sizep = get_size_ptr()

    local rc = ngx_lua_ffi_ssl_raw_client_addr(r, charpp, sizep,
                                                      intp, errmsg)
    if rc == FFI_OK then
        local typ = addr_types[intp[0]]
        if not typ then
            return nil, nil, "unknown address type: " .. intp[0]
        end
        return ffi_str(charpp[0], sizep[0]), typ
    end

    return nil, nil, ffi_str(errmsg[0])
end


function _M.cert_pem_to_der(pem)
    local outbuf = get_string_buf(#pem)

    local sz = ngx_lua_ffi_cert_pem_to_der(pem, #pem, outbuf, errmsg)
    if sz > 0 then
        return ffi_str(outbuf, sz)
    end

    return nil, ffi_str(errmsg[0])
end


function _M.priv_key_pem_to_der(pem)
    local outbuf = get_string_buf(#pem)

    local sz = ngx_lua_ffi_priv_key_pem_to_der(pem, #pem, outbuf, errmsg)
    if sz > 0 then
        return ffi_str(outbuf, sz)
    end

    return nil, ffi_str(errmsg[0])
end


local function get_tls1_version()

    local r = getfenv(0).__ngx_req
    if not r then
        error("no request found")
    end

    local ver = ngx_lua_ffi_ssl_get_tls1_version(r, errmsg)

    ver = tonumber(ver)

    if ver >= 0 then
        return ver
    end

    -- rc == FFI_ERROR

    return nil, ffi_str(errmsg[0])
end
_M.get_tls1_version = get_tls1_version


function _M.parse_pem_cert(pem)
    local cert = ngx_lua_ffi_parse_pem_cert(pem, #pem, errmsg)
    if cert ~= nil then
        return ffi_gc(cert, ngx_lua_ffi_free_cert)
    end

    return nil, ffi_str(errmsg[0])
end


function _M.parse_pem_priv_key(pem)
    local pkey = ngx_lua_ffi_parse_pem_priv_key(pem, #pem, errmsg)
    if pkey ~= nil then
        return ffi_gc(pkey, ngx_lua_ffi_free_priv_key)
    end

    return nil, ffi_str(errmsg[0])
end


function _M.set_cert(cert)
    local r = getfenv(0).__ngx_req
    if not r then
        error("no request found")
    end

    local rc = ngx_lua_ffi_set_cert(r, cert, errmsg)
    if rc == FFI_OK then
        return true
    end

    return nil, ffi_str(errmsg[0])
end


function _M.set_priv_key(priv_key)
    local r = getfenv(0).__ngx_req
    if not r then
        error("no request found")
    end

    local rc = ngx_lua_ffi_set_priv_key(r, priv_key, errmsg)
    if rc == FFI_OK then
        return true
    end

    return nil, ffi_str(errmsg[0])
end


do
    _M.SSL3_VERSION = 0x0300
    _M.TLS1_VERSION = 0x0301
    _M.TLS1_1_VERSION = 0x0302
    _M.TLS1_2_VERSION = 0x0303

    local map = {
        [_M.SSL3_VERSION] = "SSLv3",
        [_M.TLS1_VERSION] = "TLSv1",
        [_M.TLS1_1_VERSION] = "TLSv1.1",
        [_M.TLS1_2_VERSION] = "TLSv1.2",
    }

    function _M.get_tls1_version_str()
        local ver, err = get_tls1_version()
        if not ver then
            return nil, err
        end
        return map[ver]
    end
end


return _M
