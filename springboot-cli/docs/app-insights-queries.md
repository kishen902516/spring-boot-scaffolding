# Application Insights KQL Queries

Comprehensive KQL (Kusto Query Language) queries for monitoring Spring Boot applications in Azure Application Insights.

## Table of Contents

- [Request Performance](#request-performance)
- [Dependency Tracking](#dependency-tracking)
- [Custom Events](#custom-events)
- [Exceptions](#exceptions)
- [Metrics](#metrics)
- [Availability](#availability)
- [Distributed Tracing](#distributed-tracing)
- [Business Analytics](#business-analytics)

---

## Request Performance

### Request Duration P50, P95, P99

```kusto
requests
| where timestamp > ago(1h)
| summarize
    P50 = percentile(duration, 50),
    P95 = percentile(duration, 95),
    P99 = percentile(duration, 99),
    AvgDuration = avg(duration),
    RequestCount = count()
  by operation_Name
| order by P99 desc
```

### Slowest Endpoints

```kusto
requests
| where timestamp > ago(24h)
| where duration > 1000  // > 1 second
| summarize
    Count = count(),
    AvgDuration = avg(duration),
    MaxDuration = max(duration)
  by operation_Name, resultCode
| order by AvgDuration desc
| take 20
```

### Request Success Rate

```kusto
requests
| where timestamp > ago(1h)
| summarize
    TotalRequests = count(),
    SuccessRequests = countif(success == true),
    FailedRequests = countif(success == false),
    SuccessRate = round(100.0 * countif(success == true) / count(), 2)
  by bin(timestamp, 5m), operation_Name
| render timechart
```

### HTTP Status Code Distribution

```kusto
requests
| where timestamp > ago(1h)
| summarize Count = count() by resultCode
| order by Count desc
| render piechart
```

### Requests by Hour of Day

```kusto
requests
| where timestamp > ago(7d)
| extend Hour = datetime_part("hour", timestamp)
| summarize Count = count(), AvgDuration = avg(duration) by Hour
| order by Hour asc
| render columnchart
```

---

## Dependency Tracking

### External Service Performance

```kusto
dependencies
| where timestamp > ago(1h)
| summarize
    Count = count(),
    SuccessRate = round(100.0 * countif(success == true) / count(), 2),
    AvgDuration = avg(duration),
    P95Duration = percentile(duration, 95)
  by name, type
| order by Count desc
```

### Failed Dependency Calls

```kusto
dependencies
| where timestamp > ago(1h)
| where success == false
| project
    timestamp,
    name,
    type,
    target,
    resultCode,
    duration,
    operation_Id
| order by timestamp desc
| take 100
```

### Dependency Call Trends

```kusto
dependencies
| where timestamp > ago(24h)
| summarize
    Count = count(),
    Failures = countif(success == false)
  by bin(timestamp, 1h), name
| render timechart
```

### Circuit Breaker Status (via Custom Events)

```kusto
customEvents
| where timestamp > ago(1h)
| where name endswith "Fallback"
| summarize Count = count() by name, tostring(customDimensions.reason)
| order by Count desc
```

---

## Custom Events

### Business Events Summary

```kusto
customEvents
| where timestamp > ago(24h)
| where name in ("OrderCreated", "OrderCompleted", "PaymentProcessed")
| summarize Count = count() by name, bin(timestamp, 1h)
| render timechart
```

### Order Processing Metrics

```kusto
customEvents
| where timestamp > ago(24h)
| where name == "OrderProcessed"
| extend
    OrderValue = todouble(customMeasurements.orderValue),
    ItemCount = todouble(customMeasurements.itemCount)
| summarize
    TotalOrders = count(),
    TotalRevenue = sum(OrderValue),
    AvgOrderValue = avg(OrderValue),
    AvgItemsPerOrder = avg(ItemCount)
  by bin(timestamp, 1h)
| project timestamp, TotalOrders, TotalRevenue, AvgOrderValue, AvgItemsPerOrder
```

### User Activity

```kusto
customEvents
| where timestamp > ago(7d)
| extend UserId = tostring(customDimensions.userId)
| summarize
    Events = count(),
    UniqueUsers = dcount(UserId)
  by bin(timestamp, 1d)
| render timechart
```

---

## Exceptions

### Exception Trends

```kusto
exceptions
| where timestamp > ago(24h)
| summarize Count = count() by bin(timestamp, 1h), type
| render timechart
```

### Top Exceptions

```kusto
exceptions
| where timestamp > ago(24h)
| summarize
    Count = count(),
    SampleMessage = any(outerMessage)
  by type, method
| order by Count desc
| take 20
```

### Exception Details

```kusto
exceptions
| where timestamp > ago(1h)
| project
    timestamp,
    type,
    outerMessage,
    method,
    assembly,
    operation_Id,
    severityLevel
| order by timestamp desc
| take 100
```

### Exceptions by User

```kusto
exceptions
| where timestamp > ago(24h)
| extend UserId = tostring(customDimensions.userId)
| where isnotempty(UserId)
| summarize Count = count() by UserId, type
| order by Count desc
| take 20
```

---

## Metrics

### Custom Metrics

```kusto
customMetrics
| where timestamp > ago(1h)
| summarize
    Avg = avg(value),
    Min = min(value),
    Max = max(value),
    P95 = percentile(value, 95)
  by name, bin(timestamp, 5m)
| render timechart
```

### JVM Memory Usage

```kusto
performanceCounters
| where timestamp > ago(1h)
| where name == "% Process CPU" or name == "Process Private Bytes"
| summarize Avg = avg(value) by name, bin(timestamp, 5m)
| render timechart
```

---

## Availability

### Service Availability

```kusto
requests
| where timestamp > ago(24h)
| summarize
    TotalRequests = count(),
    SuccessfulRequests = countif(success == true),
    Availability = round(100.0 * countif(success == true) / count(), 2)
  by bin(timestamp, 1h)
| render timechart
```

### Health Check Status

```kusto
requests
| where timestamp > ago(1h)
| where url endswith "/actuator/health"
| summarize Count = count(), FailureCount = countif(resultCode != "200") by bin(timestamp, 5m)
| render timechart
```

---

## Distributed Tracing

### Request End-to-End Journey

```kusto
// Replace with your operation_Id
let operationId = "YOUR_OPERATION_ID";
union requests, dependencies, exceptions, traces
| where operation_Id == operationId
| project
    timestamp,
    itemType,
    name,
    duration,
    success,
    resultCode
| order by timestamp asc
```

### Trace Correlation

```kusto
requests
| where timestamp > ago(1h)
| where name == "POST /api/orders"
| join kind=inner (
    dependencies
    | where timestamp > ago(1h)
  ) on operation_Id
| project
    RequestTime = timestamp,
    RequestName = name,
    RequestDuration = duration,
    DependencyName = name1,
    DependencyDuration = duration1,
    DependencySuccess = success1
| order by RequestTime desc
| take 100
```

---

## Business Analytics

### Revenue by Hour

```kusto
customEvents
| where timestamp > ago(7d)
| where name == "OrderProcessed"
| extend Revenue = todouble(customMeasurements.orderValue)
| summarize TotalRevenue = sum(Revenue) by bin(timestamp, 1h)
| render timechart
```

### Conversion Funnel

```kusto
let timeRange = ago(1d);
let cartAdded = customEvents
| where timestamp > timeRange
| where name == "ProductAddedToCart"
| summarize CartCount = dcount(session_Id);
let checkoutStarted = customEvents
| where timestamp > timeRange
| where name == "CheckoutStarted"
| summarize CheckoutCount = dcount(session_Id);
let orderCompleted = customEvents
| where timestamp > timeRange
| where name == "OrderCompleted"
| summarize OrderCount = dcount(session_Id);
print
    Step = "Cart",
    Count = toscalar(cartAdded),
    ConversionRate = 100.0
union (
  print
    Step = "Checkout",
    Count = toscalar(checkoutStarted),
    ConversionRate = round(100.0 * toscalar(checkoutStarted) / toscalar(cartAdded), 2)
)
union (
  print
    Step = "Order",
    Count = toscalar(orderCompleted),
    ConversionRate = round(100.0 * toscalar(orderCompleted) / toscalar(checkoutStarted), 2)
)
```

### Top Products

```kusto
customEvents
| where timestamp > ago(7d)
| where name == "ProductViewed"
| extend ProductId = tostring(customDimensions.productId)
| summarize Views = count() by ProductId
| order by Views desc
| take 10
```

### User Retention

```kusto
let startDate = ago(30d);
customEvents
| where timestamp > startDate
| extend UserId = tostring(customDimensions.userId)
| extend Day = startofday(timestamp)
| summarize FirstSeen = min(Day), LastSeen = max(Day) by UserId
| extend DaysActive = datetime_diff('day', LastSeen, FirstSeen) + 1
| summarize
    TotalUsers = dcount(UserId),
    AvgDaysActive = avg(DaysActive)
  by bin(FirstSeen, 7d)
| render columnchart
```

---

## Alerting Queries

### High Error Rate

```kusto
requests
| where timestamp > ago(5m)
| summarize
    TotalRequests = count(),
    FailedRequests = countif(success == false),
    ErrorRate = round(100.0 * countif(success == false) / count(), 2)
| where ErrorRate > 5  // Alert if error rate > 5%
```

### Slow Dependency

```kusto
dependencies
| where timestamp > ago(5m)
| where duration > 5000  // > 5 seconds
| summarize Count = count() by name
| where Count > 10  // Alert if more than 10 slow calls
```

### Exception Spike

```kusto
exceptions
| where timestamp > ago(5m)
| summarize Count = count()
| where Count > 50  // Alert if more than 50 exceptions in 5 minutes
```

---

## Performance Optimization Queries

### Find Slow Database Queries

```kusto
dependencies
| where timestamp > ago(1h)
| where type == "SQL"
| where duration > 1000  // > 1 second
| project
    timestamp,
    name,
    target,
    duration,
    data,
    operation_Id
| order by duration desc
| take 50
```

### Identify Memory Leaks

```kusto
performanceCounters
| where timestamp > ago(24h)
| where name == "Process Private Bytes"
| summarize Avg = avg(value) by bin(timestamp, 1h)
| render timechart
```

### Cache Hit Rate

```kusto
customMetrics
| where timestamp > ago(1h)
| where name in ("cache.hit", "cache.miss")
| summarize Count = sum(value) by name
| extend Total = sumif(value, name == "cache.hit") + sumif(value, name == "cache.miss")
| extend HitRate = round(100.0 * sumif(value, name == "cache.hit") / Total, 2)
```

---

## Workbook Templates

### Real-Time Dashboard

```kusto
let timeRange = ago(1h);
let requests_data = requests
| where timestamp > timeRange
| summarize RequestCount = count(), AvgDuration = avg(duration) by bin(timestamp, 5m);
let exceptions_data = exceptions
| where timestamp > timeRange
| summarize ExceptionCount = count() by bin(timestamp, 5m);
requests_data
| join kind=fullouter exceptions_data on timestamp
| project
    timestamp = coalesce(timestamp, timestamp1),
    RequestCount,
    AvgDuration,
    ExceptionCount = coalesce(ExceptionCount, 0)
| render timechart
```

---

**Tip**: Save frequently used queries as functions in Application Insights for quick access.

**Documentation**: [KQL Quick Reference](https://learn.microsoft.com/en-us/azure/data-explorer/kql-quick-reference)
