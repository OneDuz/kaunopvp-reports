RegisterNetEvent('aimbot:showReports', function(reports)
    local options = {}

    local sortedReports = {}
    for identifier, reportData in pairs(reports) do
        table.insert(sortedReports, {
            identifier = identifier,
            count = reportData.count,
            reports = reportData.reports,
            serverId = reportData.serverId,
            steamName = reportData.steamName
        })
    end
    table.sort(sortedReports, function(a, b) return a.count > b.count end)

    for _, report in ipairs(sortedReports) do
        local playerSteam = report.identifier
        local reportCount = report.count
        local reportDetails = report.reports
        local playerServerId = report.serverId
        local playerSteamName = report.steamName

        table.insert(options, {
            title = playerSteamName .. ' (' .. playerServerId .. ')' .. ' - Reports: ' .. reportCount,
            description = 'Click for more details',
            icon = 'circle',
            onSelect = function()
                local detailOptions = {}
                for reporterIdentifier, details in pairs(reportDetails) do
                    local reportTime = details.time
                    local reporterSteamName = details.reporterSteamName
                    table.insert(detailOptions, {
                        title = reporterSteamName,
                        description = 'Reported at: ' .. reportTime,
                        icon = 'circle',
                    })
                end
                lib.registerContext({
                    id = 'aimbot_report_details_' .. playerServerId,
                    title = 'Report Details for ' .. playerSteamName,
                    options = detailOptions
                })
                lib.showContext('aimbot_report_details_' .. playerServerId)
            end,
        })
    end

    lib.registerContext({
        id = 'aimbot_reports_menu',
        title = 'Aimbot Reports Leaderboard',
        options = options
    })

    lib.showContext('aimbot_reports_menu')
end)
