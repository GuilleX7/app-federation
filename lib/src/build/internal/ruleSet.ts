import path from 'node:path';
import type { RuleSetCondition, RuleSetRule } from '@rspack/core';
import type { JsResolveData } from '@rspack/binding';

type ResourceParts = {
  path: string;
  query: string | undefined;
  fragment: string | undefined;
  scheme: string | undefined;
};

const isObject = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null;

function matchesCondition(condition: RuleSetCondition, value: string): boolean {
  if (typeof condition === 'string') {
    return condition === '' ? value === '' : value.startsWith(condition);
  }

  if (condition instanceof RegExp) {
    condition.lastIndex = 0;
    const matched = condition.test(value);
    condition.lastIndex = 0;
    return matched;
  }

  if (typeof condition === 'function') {
    try {
      return condition(value);
    } catch {
      return false;
    }
  }

  if (Array.isArray(condition)) {
    return condition.some((item) => matchesCondition(item, value));
  }

  if (!isObject(condition)) {
    return false;
  }

  const checks: boolean[] = [];

  if (condition.or !== undefined) {
    checks.push(
      Array.isArray(condition.or) &&
        condition.or.some((item) => matchesCondition(item, value)),
    );
  }

  if (condition.and !== undefined) {
    checks.push(
      Array.isArray(condition.and) &&
        condition.and.every((item) => matchesCondition(item, value)),
    );
  }

  if (condition.not !== undefined) {
    checks.push(!matchesCondition(condition.not as RuleSetCondition, value));
  }

  return checks.length > 0 && checks.every(Boolean);
}

function matchesOptionalCondition(
  condition: RuleSetCondition | undefined,
  value: string | undefined,
): boolean {
  return condition === undefined
    ? true
    : matchesCondition(condition, value ?? '');
}

function splitResource(resource: string): {
  resourcePath: string;
  query: string | undefined;
  fragment: string | undefined;
  scheme: string | undefined;
} {
  const fragmentIndex = resource.indexOf('#');
  const withoutFragment =
    fragmentIndex === -1 ? resource : resource.slice(0, fragmentIndex);
  const queryIndex = withoutFragment.indexOf('?');
  const resourcePath =
    queryIndex === -1 ? withoutFragment : withoutFragment.slice(0, queryIndex);

  const schemeMatch =
    /^[A-Za-z][A-Za-z0-9+.-]*:/.exec(resourcePath) &&
    !/^[A-Za-z]:[\\/]/.test(resourcePath)
      ? /^([A-Za-z][A-Za-z0-9+.-]*):/.exec(resourcePath)
      : undefined;

  return {
    resourcePath,
    query: queryIndex === -1 ? undefined : withoutFragment.slice(queryIndex),
    fragment: fragmentIndex === -1 ? undefined : resource.slice(fragmentIndex),
    scheme: schemeMatch?.[1],
  };
}

function getResourceParts(resolveData: JsResolveData): ResourceParts {
  const resource = resolveData.createData?.resource ?? resolveData.request;
  const parts = splitResource(resource);
  let resourcePath = parts.resourcePath;

  if (parts.scheme?.toLowerCase() === 'data') {
    resourcePath = '';
  } else if (parts.scheme === undefined && !path.isAbsolute(resourcePath)) {
    resourcePath = path.resolve(resolveData.context, resourcePath);
  }

  return {
    path: resourcePath,
    query: parts.query,
    fragment: parts.fragment,
    scheme: parts.scheme,
  };
}

function matchesRuleConditions(
  resolveData: JsResolveData,
  rule: RuleSetRule,
): boolean {
  const resource = getResourceParts(resolveData);

  if (rule.test !== undefined && !matchesCondition(rule.test, resource.path)) {
    return false;
  }

  if (
    rule.resource !== undefined &&
    !matchesCondition(rule.resource, resource.path)
  ) {
    return false;
  }

  if (
    rule.include !== undefined &&
    !matchesCondition(rule.include, resource.path)
  ) {
    return false;
  }

  if (
    rule.exclude !== undefined &&
    matchesCondition(rule.exclude, resource.path)
  ) {
    return false;
  }

  if (
    rule.resourceQuery !== undefined &&
    !matchesOptionalCondition(rule.resourceQuery, resource.query)
  ) {
    return false;
  }

  if (
    rule.resourceFragment !== undefined &&
    !matchesOptionalCondition(rule.resourceFragment, resource.fragment)
  ) {
    return false;
  }

  if (
    rule.scheme !== undefined &&
    !matchesOptionalCondition(rule.scheme, resource.scheme)
  ) {
    return false;
  }

  if (
    rule.issuer !== undefined &&
    !matchesOptionalCondition(rule.issuer, resolveData.contextInfo.issuer)
  ) {
    return false;
  }

  if (
    rule.issuerLayer !== undefined &&
    !matchesOptionalCondition(
      rule.issuerLayer,
      resolveData.contextInfo.issuerLayer,
    )
  ) {
    return false;
  }

  return true;
}

function isRule(value: unknown): value is RuleSetRule {
  return isObject(value);
}

export function matchesRuleSetRule(
  resolveData: JsResolveData,
  rule: RuleSetRule,
): boolean {
  if (!matchesRuleConditions(resolveData, rule)) {
    return false;
  }

  if (
    rule.oneOf !== undefined &&
    !rule.oneOf.some(
      (nestedRule) =>
        isRule(nestedRule) && matchesRuleSetRule(resolveData, nestedRule),
    )
  ) {
    return false;
  }

  return true;
}
