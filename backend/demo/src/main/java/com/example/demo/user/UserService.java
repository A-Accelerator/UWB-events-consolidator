package com.example.demo.user;

import java.util.List;
import java.util.Optional;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.Event.Event;
import com.example.demo.Event.EventRepository;

/**
 * Service class for handling user-related operations.
 */
@Service
public class UserService {

    // Repository to handle CRUD operations on User entities
    private final UserRepository userRepository;
    private final EventRepository eventRepository;

    /**
     * Constructor for UserService.
     *
     * @param userRepository the repository to handle user operations
     */
    @Autowired
    public UserService(UserRepository userRepository, EventRepository eventRepository) {
        this.userRepository = userRepository;
        this.eventRepository = eventRepository;
    }

    /**
     * Retrieves all users from the repository.
     *
     * @return a list of all users
     */
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    /**
     * Adds a new user to the repository.
     *
     * @param user the user object to be added
     */
    public void addUser(User user) {
        //Uncomment when in production
        /*Optional<User> possibleUser = userRepository.findByUserName(user.getUserName());
        if (possibleUser.isPresent()) {
            throw new IllegalArgumentException("User already exists");
        }*/
        userRepository.save(user);
    }

    /**
     * Finds all events for the user to be used in events cal
     * @param ID id of student
     * @return events the student has joined
     * @throws IllegalArgumentException if the student does not exist
     */
    public Set<Event> eventsForUser(Integer ID) throws IllegalArgumentException{
        Optional<User> possibleUser = userRepository.findById(ID);
        if(possibleUser.isPresent()) {
            return possibleUser.get().getEvents();
        }else{
            throw new IllegalArgumentException("User not found");
        }

    }

    /**
     * Adds user to the event
     * @param userId the event of the user
     * @param eventId the event of the ID
     * @throws IllegalArgumentException if the user is already in the event or the event or user is not present
     */
    public void addUserToEvent(Integer userId, Integer eventId) throws IllegalArgumentException {
        Optional<User> userOpt = userRepository.findById(userId);
        Optional<Event> eventOpt = eventRepository.findById(eventId);
        if (userOpt.isPresent() && eventOpt.isPresent()) {
            if(eventOpt.get().getSignedUpUsers().contains(userOpt.get())) {
                throw new IllegalArgumentException("User already has an event");
            }
            User user = userOpt.get();
            Event event = eventOpt.get();
            user.getEvents().add(event);
            userRepository.save(user);
        } else if (!userOpt.isPresent()) {
            throw new IllegalArgumentException("User not found");
        }
        else  {
            throw new IllegalArgumentException("Event not found");
        }
    }
    /*
     * Logic for finding if the user is an admin
     * @param id  of user searching for 
     * @return admin powers of user if found
     */
    public Boolean isAdmin(Integer id){
        Optional<User> possibleUser = userRepository.findById(id);
        if(possibleUser.isPresent()) {
            return possibleUser.get().getAdminPowers();
        }else{
            throw new IllegalArgumentException("User not found");
        }
    
    }
}
