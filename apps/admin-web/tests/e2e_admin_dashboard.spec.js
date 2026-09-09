import { test, expect } from '@playwright/test';

test.describe('Aivo Web Admin Dashboard & Huberman RAG E2E Suite', () => {
  const BASE_URL = process.env.ADMIN_URL || 'http://localhost:3000';

  test.beforeEach(async ({ page }) => {
    await page.goto(BASE_URL);
  });

  test('1. Dashboard Vitals Check — Should render real-time metric cards', async ({ page }) => {
    // Verify Page Header
    await expect(page.locator('h1')).toContainText(/AIVO.*ADMIN/i);

    // Verify System Vitals Cards
    const activeUsersCard = page.locator('text=Active Monitored Users').locator('..');
    await expect(activeUsersCard).toBeVisible();
    await expect(activeUsersCard).toContainText(/1,420|1420/);

    const pairedCouplesCard = page.locator('text=Paired Couple Links').locator('..');
    await expect(pairedCouplesCard).toBeVisible();
    await expect(pairedCouplesCard).toContainText('680');

    const helpfulRateCard = page.locator('text=Nudge Helpful Rate').locator('..');
    await expect(helpfulRateCard).toBeVisible();
    await expect(helpfulRateCard).toContainText(/89\.4%/);

    const simulatorCard = page.locator('text=Simulator Engine').locator('..');
    await expect(simulatorCard).toBeVisible();
    await expect(simulatorCard).toContainText(/Healthy|STREAMING/i);
  });

  test('2. Real-Time Prediction Stream — Should render feed with CSI badges', async ({ page }) => {
    // Check Feed Header
    await expect(page.getByText('LIVE PREDICTION STREAM')).toBeVisible();

    // Check Anonymized User Entry
    const userRow = page.locator('text=USR-8192');
    await expect(userRow).toBeVisible();

    // Check Cycle Day & Phase Badge
    await expect(page.locator('text=Day 24 • luteal')).toBeVisible();

    // Check CSI Gauge Badge (>= 70% Alert)
    const csiBadge = page.locator('text=CSI 88%');
    await expect(csiBadge).toBeVisible();

    // Check Partner Nudge Status
    await expect(page.locator('text=Nudge: Delivered')).toBeVisible();
  });

  test('3. Huberman GenAI Assistant — Should submit prompt and show citations', async ({ page }) => {
    // Check Chat Assistant Header
    await expect(page.getByText('HUBERMAN RAG ASSISTANT')).toBeVisible();

    // Click Quick-Prompt Button: "Find protocols for high cortisol"
    const quickPromptBtn = page.getByRole('button', { name: /Find protocols for high cortisol/i });
    await expect(quickPromptBtn).toBeVisible();
    await quickPromptBtn.click();

    // Verify that user message appears in chat history
    await expect(page.locator('text=Find protocols for high cortisol')).toBeVisible();

    // Verify AI response generation
    const aiResponseLocator = page.locator('text=Dr. Huberman').or(page.locator('text=Physiological Sigh'));
    await expect(aiResponseLocator.first()).toBeVisible({ timeout: 10000 });

    // Confirm collapsible "Sources & Protocols" badge displays
    const sourcesBadge = page.locator('button:has-text("Sources")');
    await expect(sourcesBadge.first()).toBeVisible({ timeout: 5000 });

    // Click to expand source citation card
    await sourcesBadge.first().click();

    // Verify episode citations appear
    await expect(page.locator('text=Tools for Managing Stress & Anxiety').first()).toBeVisible();
    await expect(page.locator('text=Protocol:').first()).toBeVisible();
  });
});
