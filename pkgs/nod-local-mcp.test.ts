import assert from 'node:assert/strict';
import test from 'node:test';
import Fastify from 'fastify';
import {
  createDiscoveredTransport,
  ownerAddress,
  ownerFetch,
} from './src/providers/discovered/remote.ts';
import { createDiscoveredConnections } from './src/server/discovered-connections.ts';

const loopback = 'http://127.0.0.1:23373/v0/mcp';
const inserted: string[] = [];
const query = async (_sql: string, values: unknown[] = []) => {
  if (typeof values[4] === 'string') inserted.push(values[4]);
  return { rows: [], rowCount: 0 };
};
const pool = { query, connect: async () => ({ query, release() {} }) };
const connections = await createDiscoveredConnections(pool as never, {
  ownerId: 'owner',
  baseUrl: 'http://127.0.0.1:1',
  grantVault: {} as never,
  transport: createDiscoveredTransport(),
  oauth: {} as never,
  // same wiring as src/server/composition.ts
  local: (origin) => ({
    transport: createDiscoveredTransport(
      ownerFetch(origin),
      async (endpoint) => (await ownerAddress(origin)(endpoint)).url.href,
    ),
    oauth: {} as never,
  }),
});
const app = Fastify();
connections.registerRoutes(app);
const connect = (endpoint: string) =>
  app.inject({
    method: 'POST',
    url: '/api/apps/mcp',
    payload: { name: 'Test', endpoint, auth: 'bearer' },
  });
const savedPath = () => JSON.parse(inserted.pop()!)[0];

test('the owner can connect a loopback MCP server', async () => {
  assert.equal((await connect(loopback)).statusCode, 200);
  assert.deepEqual(
    { endpoint: savedPath().endpoint, local: true },
    { endpoint: loopback, local: true },
  );
});

test('a public server is not marked local', async () => {
  assert.equal((await connect('https://1.1.1.1/mcp')).statusCode, 200);
  assert.equal(savedPath().local, undefined);
});

test('a LAN address is still refused', async () => {
  assert.equal((await connect('http://192.168.1.10:8080/mcp')).statusCode, 400);
});

test('the model still cannot propose a loopback server', async () => {
  await assert.rejects(
    connections.propose({
      service: 'beeper',
      name: 'Beeper',
      paths: [{ kind: 'mcp', endpoint: loopback }],
    }),
  );
  assert.equal(inserted.length, 0);
});
