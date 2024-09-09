import React, { useState } from 'react';

function App() {
  const [formData, setFormData] = useState({
    fname: '',
    lname: '',
    email: ''
  });

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    
    fetch('http://<private-ec2-backend-url>:3000/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(formData)
    })
    .then(response => response.json())
    .then(data => {
      alert('Bilgiler başarıyla kaydedildi!');
    })
    .catch(error => {
      console.error('Error:', error);
    });
  };

  return (
    <div>
      <h1>Login Form</h1>
      <form onSubmit={handleSubmit}>
        <label>İsim:</label>
        <input type="text" name="fname" onChange={handleChange} />
        <label>Soyisim:</label>
        <input type="text" name="lname" onChange={handleChange} />
        <label>Email:</label>
        <input type="email" name="email" onChange={handleChange} />
        <button type="submit">Gönder</button>
      </form>
    </div>
  );
}

export default App;
