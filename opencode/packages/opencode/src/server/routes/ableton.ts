import { Hono } from "hono"
import { describeRoute, validator, resolver } from "hono-openapi"
import z from "zod"
import { lazy } from "../../util/lazy"
import { Log } from "../../util/log"
import { AbletonBridge } from "../../osc/ableton-bridge"

const log = Log.create({ service: "ableton-routes" })

export const AbletonRoutes = lazy(() =>
  new Hono()
    .post(
      "/connect",
      describeRoute({
        summary: "Connect to Ableton",
        description: "Connect to Ableton Live via AbletonOSC UDP bridge.",
        operationId: "ableton.connect",
        responses: {
          200: {
            description: "Connection result",
            content: {
              "application/json": {
                schema: resolver(
                  z.object({
                    connected: z.boolean(),
                    host: z.string(),
                    port: z.number(),
                  }),
                ),
              },
            },
          },
        },
      }),
      validator(
        "json",
        z.object({
          host: z.string().optional().meta({ description: "OSC host (default 127.0.0.1)" }),
          port: z.number().optional().meta({ description: "OSC port (default 11000)" }),
        }),
      ),
      async (c) => {
        const { host, port } = c.req.valid("json")
        log.info("connect request", { host, port })

        await AbletonBridge.connect({ host, port })

        return c.json({
          connected: true,
          host: host ?? "127.0.0.1",
          port: port ?? 11000,
        })
      },
    )
    .post(
      "/disconnect",
      describeRoute({
        summary: "Disconnect from Ableton",
        description: "Disconnect the AbletonOSC UDP bridge.",
        operationId: "ableton.disconnect",
        responses: {
          200: {
            description: "Disconnection result",
            content: {
              "application/json": {
                schema: resolver(z.boolean()),
              },
            },
          },
        },
      }),
      async (c) => {
        log.info("disconnect request")
        AbletonBridge.disconnect()
        return c.json(true)
      },
    )
    .get(
      "/status",
      describeRoute({
        summary: "Get Ableton connection status",
        description: "Check the current connection status to Ableton Live via AbletonOSC.",
        operationId: "ableton.status",
        responses: {
          200: {
            description: "Connection status",
            content: {
              "application/json": {
                schema: resolver(
                  z.object({
                    connected: z.boolean(),
                    alive: z.boolean(),
                  }),
                ),
              },
            },
          },
        },
      }),
      async (c) => {
        const { isConnected } = await import("../../osc/ableton-bridge").then((m) => m.AbletonBridge)
        const { AbletonOSC } = await import("../../osc/client")
        return c.json({
          connected: isConnected(),
          alive: AbletonOSC.isAlive(),
        })
      },
    )
    .get(
      "/tracks",
      describeRoute({
        summary: "List Ableton tracks",
        description: "Get the list of tracks from the connected Ableton Live session.",
        operationId: "ableton.tracks",
        responses: {
          200: {
            description: "Track list",
            content: {
              "application/json": {
                schema: resolver(
                  z.object({
                    tracks: z.array(
                      z.object({
                        index: z.number(),
                        name: z.string(),
                      }),
                    ),
                  }),
                ),
              },
            },
          },
        },
      }),
      async (c) => {
        if (!AbletonBridge.isConnected()) {
          return c.json({ tracks: [] })
        }

        try {
          const result = await AbletonBridge.getTrackList()
          return c.json(result)
        } catch (e) {
          log.error("failed to get tracks", { error: e })
          return c.json({ tracks: [] })
        }
      },
    ),
)
