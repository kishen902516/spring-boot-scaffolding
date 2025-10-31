package com.example.infrastructure.adapter.client;

import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

/**
 * Payment service client
 * VIOLATION: Missing port interface implementation
 */
@Component
public class PaymentClient {

    private final RestTemplate restTemplate;

    public PaymentClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public PaymentResponse processPayment(PaymentRequest request) {
        // Make external API call
        return restTemplate.postForObject(
            "https://api.payment.com/process",
            request,
            PaymentResponse.class
        );
    }

    public PaymentStatus checkStatus(String paymentId) {
        return restTemplate.getForObject(
            "https://api.payment.com/status/" + paymentId,
            PaymentStatus.class
        );
    }
}

class PaymentRequest {
    private String amount;
    private String currency;
    // getters and setters
}

class PaymentResponse {
    private String transactionId;
    private String status;
    // getters and setters
}

class PaymentStatus {
    private String status;
    private String message;
    // getters and setters
}