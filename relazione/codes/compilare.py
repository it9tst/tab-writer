# Create model
model = Model(inputs = model_in, 
                outputs = [out1, out2, out3, out4, out5, out6])
model.compile(optimizer = sgd, 
                loss = ['categorical_crossentropy', 
                        'categorical_crossentropy', 
                        'categorical_crossentropy', 
                        'categorical_crossentropy', 
                        'categorical_crossentropy', 
                        'categorical_crossentropy'], 
              metrics = ['accuracy'])