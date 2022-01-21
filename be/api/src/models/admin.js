const joi = require("joi");

const adminSchema = {
	_id: String,
  name: String,
  email: {
		type: String,
		lowercase: true,
		match: /[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/,
  },
  password: String,
  phone_number: Number,
};

module.exports = adminSchema