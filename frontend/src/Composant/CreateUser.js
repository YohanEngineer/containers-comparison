import React, { useState } from 'react';
import { createUser } from '../Service/apiService';
import { Form, Button } from 'react-bootstrap';

const CreateUser = () => {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");

  const submitForm = async (e) => {
    e.preventDefault();
    try {
      const response = await createUser({ name, email });
      console.log(response.data);  // Vous pouvez gérer la réponse de l'API comme vous le souhaitez
      setName("");
      setEmail("");
      // refresh the page
      window.location.reload();
    } catch (error) {
      console.error(error);  // Vous devriez probablement afficher une notification d'erreur à l'utilisateur
    }
  };

  return (
    <Form onSubmit={submitForm}>
      <Form.Group controlId="formBasicName">
        <Form.Label>Name:</Form.Label>
        <Form.Control type="text" value={name} onChange={e => setName(e.target.value)} required />
      </Form.Group>
      <Form.Group controlId="formBasicEmail">
        <Form.Label>Email:</Form.Label>
        <Form.Control type="email" value={email} onChange={e => setEmail(e.target.value)} required />
      </Form.Group>
      <Button variant="primary" type="submit">
        Create user
      </Button>
    </Form>
  );
};

export default CreateUser;
