package com.example.api.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import java.math.BigDecimal;

/**
 * Order REST controller
 * VIOLATION: Business logic in controller layer
 */
@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderRepository orderRepository;

    public OrderController(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    @PostMapping
    public ResponseEntity<OrderResponse> createOrder(@RequestBody OrderRequest request) {
        // VIOLATION: Business logic should not be in controller
        if (request.getTotalAmount().compareTo(new BigDecimal("10000")) > 0) {
            // High-value order processing
            request.setStatus("REQUIRES_APPROVAL");

            // Calculate discount (business logic!)
            BigDecimal discount = request.getTotalAmount().multiply(new BigDecimal("0.05"));
            request.setDiscountAmount(discount);

            // Validate customer credit limit (business logic!)
            if (request.getTotalAmount().compareTo(new BigDecimal("50000")) > 0) {
                return ResponseEntity.badRequest().body(
                    new OrderResponse("Order exceeds credit limit", null)
                );
            }
        } else {
            request.setStatus("APPROVED");
        }

        // Direct repository call instead of using use case
        Order order = orderRepository.save(convertToOrder(request));

        return ResponseEntity.ok(new OrderResponse("Order created", order.getId()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Order> getOrder(@PathVariable String id) {
        // VIOLATION: Returning domain entity directly instead of DTO
        return orderRepository.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    // Helper method (should be in mapper)
    private Order convertToOrder(OrderRequest request) {
        Order order = new Order();
        order.setCustomerName(request.getCustomerName());
        order.setTotalAmount(request.getTotalAmount());
        order.setStatus(request.getStatus());
        return order;
    }
}

class OrderRequest {
    private String customerName;
    private BigDecimal totalAmount;
    private String status;
    private BigDecimal discountAmount;

    // getters and setters
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setStatus(String status) { this.status = status; }
    public void setDiscountAmount(BigDecimal amount) { this.discountAmount = amount; }
    public String getCustomerName() { return customerName; }
    public String getStatus() { return status; }
}

class OrderResponse {
    private String message;
    private String orderId;

    public OrderResponse(String message, String orderId) {
        this.message = message;
        this.orderId = orderId;
    }

    // getters
}

interface OrderRepository {
    Order save(Order order);
    java.util.Optional<Order> findById(String id);
}

class Order {
    private String id;
    private String customerName;
    private BigDecimal totalAmount;
    private String status;

    // getters and setters
    public String getId() { return id; }
    public void setCustomerName(String name) { this.customerName = name; }
    public void setTotalAmount(BigDecimal amount) { this.totalAmount = amount; }
    public void setStatus(String status) { this.status = status; }
}