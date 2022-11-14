# frozen_string_literal: true

require 'rack'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'
require './app'

use LoginGov::HandleBadEncodingMiddleware
use Rack::Deflater
use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

run LoginGov::FakeVendorServer.new
