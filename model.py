import numpy as np
from keras.models import Sequential
from dataModel import dataModel

# Parameters
params = {'dim': (32,32,32), 'batch_size': 192, 'n_classes': 6, 'n_channels': 1, 'shuffle': True}

# Datasets
partition = # IDs
labels = # Labels

# Generators
training_generator = DataGenerator(partition['train'], labels, **params)
validation_generator = DataGenerator(partition['validation'], labels, **params)

# Design model
model = Sequential()
[...] # Architecture
model.compile()

# Train model on dataset
model.fit_generator(generator=training_generator,
                    validation_data=validation_generator,
                    use_multiprocessing=True,
                    workers=6)