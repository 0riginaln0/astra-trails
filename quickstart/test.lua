local lust = require 'lust'
local describe, it, expect = lust.describe, lust.it, lust.expect

local http = require 'http'
local request = http.request

local wait = require('runtime').wait

RUNNING_FROM_TEST_SUITE = true
spawn_task(function() require 'main' end); wait(2) -- Launch server

describe('My project', function()
    it('The home page is self-aware', function()
        local response = request('http://localhost:8080/'):execute():body():text()
        expect(response).to.be("I'm a homepage")
    end)
end)

TEST_SERVER:shutdown()
