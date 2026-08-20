'use strict';

// =============================================================================
// secrets.js — resolve DB credentials from AWS Secrets Manager at boot.
//
// The client only takes `endpoint: process.env.AWS_ENDPOINT_URL`. When that
// var is unset (real AWS) the SDK resolves its normal endpoint on its own —
// there is no `if (isLocalStack)` branch anywhere in this file. Region and
// credentials come from the standard AWS_REGION / AWS_ACCESS_KEY_ID /
// AWS_SECRET_ACCESS_KEY env vars the SDK already knows how to read.
// =============================================================================

const {
  SecretsManagerClient,
  GetSecretValueCommand,
} = require('@aws-sdk/client-secrets-manager');

let cached = null; // { creds: {engine,username,password,host,port,dbname}, source: {arn, versionId} }

function buildClient() {
  return new SecretsManagerClient({ endpoint: process.env.AWS_ENDPOINT_URL });
}

async function loadDbCredentials() {
  if (cached) return cached.creds;

  const arn = process.env.DB_SECRET_ARN;

  if (!arn) {
    const creds = {
      engine: 'mysql',
      username: process.env.MYSQL_USER,
      password: process.env.MYSQL_PASSWORD,
      host: process.env.MYSQL_HOST,
      port: Number(process.env.MYSQL_PORT || 3306),
      dbname: process.env.MYSQL_DATABASE,
    };
    cached = { creds, source: { arn: 'env', versionId: 'n/a' } };
    console.log('[secrets] resolved DB credentials from env (DB_SECRET_ARN unset)');
    return creds;
  }

  const client = buildClient();
  const response = await client.send(
    new GetSecretValueCommand({ SecretId: arn })
  );

  const creds = JSON.parse(response.SecretString);
  cached = {
    creds,
    source: { arn: response.ARN, versionId: response.VersionId },
  };

  console.log(
    `[secrets] resolved DB credentials from Secrets Manager arn=${response.ARN} versionId=${response.VersionId}`
  );

  return creds;
}

function getSecretSource() {
  if (!cached) return { arn: null, versionId: null };
  return cached.source;
}

module.exports = { loadDbCredentials, getSecretSource };
