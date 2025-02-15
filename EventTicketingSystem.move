// SPDX-License-Identifier: MIT
// EventTicketingSystem.move

use aptos_framework::account;
use aptos_framework::coin;
use aptos_framework::event;
use aptos_framework::storage;

// Define the EventTicketingSystem module
module EventTicketingSystem {
    // Define the Event struct
    struct Event {
        id: u64,
        name: String,
        description: String,
        date: u64,
        ticket_price: u64,
        ticket_supply: u64,
    }

    // Define the Ticket struct
    struct Ticket {
        id: u64,
        event_id: u64,
        owner: address,
    }

    // Define the EventTicketingSystem resource
    resource EventTicketingSystem {
        events: storage::HashMap<u64, Event>,
        tickets: storage::HashMap<u64, Ticket>,
        next_event_id: u64,
        next_ticket_id: u64,
    }

    // Initialize the EventTicketingSystem resource
    public entry fun initialize(ctx: &mut TxContext) {
        let events = storage::HashMap::new();
        let tickets = storage::HashMap::new();
        let next_event_id = 0;
        let next_ticket_id = 0;

        let event_ticketing_system = EventTicketingSystem {
            events,
            tickets,
            next_event_id,
            next_ticket_id,
        };

        storage::put_resource(ctx, b"EventTicketingSystem", event_ticketing_system);
    }

    // Create a new event
    public entry fun create_event(
        ctx: &mut TxContext,
        name: String,
        description: String,
        date: u64,
        ticket_price: u64,
        ticket_supply: u64,
    ) {
        let event_ticketing_system = storage::get_resource_mut(ctx, b"EventTicketingSystem");
        let next_event_id = event_ticketing_system.next_event_id;
        event_ticketing_system.next_event_id += 1;

        let event = Event {
            id: next_event_id,
            name,
            description,
            date,
            ticket_price,
            ticket_supply,
        };

        event_ticketing_system.events.insert(next_event_id, event);
    }

    // Buy a ticket for an event
    public entry fun buy_ticket(ctx: &mut TxContext, event_id: u64) {
        let event_ticketing_system = storage::get_resource_mut(ctx, b"EventTicketingSystem");
        let event = event_ticketing_system.events.get(event_id);
        assert!(event.exists(), "Event does not exist");

        let ticket_price = event.ticket_price;
        let ticket_supply = event.ticket_supply;
        assert!(ticket_supply > 0, "Tickets are sold out");

        let next_ticket_id = event_ticketing_system.next_ticket_id;
        event_ticketing_system.next_ticket_id += 1;

        let ticket = Ticket {
            id: next_ticket_id,
            event_id,
            owner: ctx.sender(),
        };

        event_ticketing_system.tickets.insert(next_ticket_id, ticket);
        event.ticket_supply -= 1;
    }

    // Get the details of an event
    public fun get_event(ctx: &TxContext, event_id: u64): Event {
        let event_ticketing_system = storage::get_resource(ctx, b"EventTicketingSystem");
        let event = event_ticketing_system.events.get(event_id);
        assert!(event.exists(), "Event does not exist");
        event
    }

    // Get the details of a ticket
    public fun get_ticket(ctx: &TxContext, ticket_id: u64): Ticket {
        let event_ticketing_system = storage::get_resource(ctx, b"EventTicketingSystem");
        let ticket = event_ticketing_system.tickets.get(ticket_id);
        assert!(ticket.exists(), "Ticket does not exist");
        ticket
    }
}