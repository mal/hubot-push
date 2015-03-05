# hubot-push

A hubot script to push messages to subscribers

See [`src/push.coffee`](src/push.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-push --save`

Then add **hubot-push** to your `external-scripts.json`:

```json
[
  "hubot-push"
]
```

## Sample Interaction

```
user1>> hubot push welcome to the badger channel to /badger
hubot>> Pushed 'welcome to the badger channel' to /badger
```

```
user1>> hubot push alias https://www.youtube.com/watch?v=dQw4w9WgXcQ to rickroll
hubot>> Hubot learned rickroll!
user1>> hubot push rickroll to /nineteeneightyseven
hubot>> Pushed https://www.youtube.com/watch?v=dQw4w9WgXcQ to /nineteeneightyseven
user1>> hubot push forget rickroll
hubot>> 1, 2 and... Poof! Hubot forgot rickroll!
user1>> hubot push rickroll to /nineteeneightyseven
hubot>> Pushed rickroll to /nineteeneightyseven
```
