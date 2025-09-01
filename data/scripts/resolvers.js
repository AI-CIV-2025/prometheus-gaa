// resolvers.js
const resolvers = {
  Query: {
    hello: () => 'Hello world!',
    sentiment: (parent, { text }, context) => {
      // TODO: Implement sentiment analysis logic
      return { score: 0.5, magnitude: 0.8 };
    },
  },
  Mutation: {
    submitReview: (parent, { text }, context) => {
      // TODO: Implement sentiment analysis and store the review
      return { score: 0.7, magnitude: 0.9 };
    },
  },
};

module.exports = resolvers;
